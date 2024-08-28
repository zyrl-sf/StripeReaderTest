//
//  MenuViewController.swift
//  StripeReaderTest
//
//  Created by Максим on 15.08.2024.
//

import UIKit

class MenuViewController: BaseViewController {
    
    var paymentRequestHandler: ((OrderRequest?, OrderResponse?) -> Void)?
    
    struct MenuItemRow {
        var isSelected: Bool
        var menuItem: MenuItem
    }
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 12
        return $0
    }(UIStackView())
    
    private lazy var summaryView: SummaryView = {
        $0.checkoutHandler = { [weak self] in
            self?.paymentRequestHandler?(self?.orderRequest, self?.orderResponse)
        }
        return $0
    }(SummaryView())
    
    private lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.register(MenuItemCell.self, forCellReuseIdentifier: "cell")
        return $0
    }(UITableView())
    
    private var items = [MenuItemRow]()
    private var orderResponse: OrderResponse?
    private var orderRequest: OrderRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Menu"
        
        view.addSubview(container)
        container.snp.makeConstraints({ 
            $0.top.equalTo(view.snp.topMargin)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottomMargin)
        })
        
        container.addArrangedSubviews([summaryView, tableView])
        
        fetchMenuItems()
    }
    
    func fetchMenuItems() {
        
        Task {
            do {
                showLoading()
                guard let id2 = LocalStorage.restaurant?.id2 else { return }
                let manager = APIManager.fetchMenuItems(locationId2: id2)
                let response: MenuResponse = try await manager.makeRequest()
                items = response.menuItems
                    .filter({ !$0.name.contains("-unavailable") })
                    .map({ MenuItemRow(isSelected: false, menuItem: $0) })
                hideLoading()
                refreshViews()
            } catch {
                hideLoading()
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func refreshViews() {
        tableView.reloadData()
    }
    
    func refreshSummary() {
        summaryView.update(orderResponse: orderResponse)
    }
    
    func calculateOrder() {
        
        let menuItems = items.filter({ $0.isSelected }).map({ $0.menuItem })
        let request = OrderRequest(menuItems: menuItems)
        orderRequest = request
        
        Task {
            do {
                showLoading()
                let manager = APIManager.calculateOrder(request: request)
                let response: OrderResponse = try await manager.makeRequest()
                orderResponse = response
                refreshSummary()
                hideLoading()
                refreshViews()
            } catch {
                hideLoading()
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.items.enumerated().forEach({ self.items[$0.offset].isSelected = false })
            self.tableView.reloadData()
            self.calculateOrder()
        }
    }
    
}


extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuItemCell
        cell.update(item: items[indexPath.row])
        return cell
    }
    
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        calculateOrder()
    }
}


class MenuItemCell: UITableViewCell {
    
    private var container: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        return $0
    }(UIStackView())
    
    private var nameLabel: UILabel = {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        return $0
    }(UILabel())
    
    private var icon: UIImageView = {
        $0.snp.makeConstraints({ $0.size.equalTo(CGSize(width: 24, height: 24)) })
        $0.image = UIImage(systemName: "checkmark.circle")
        return $0
    }(UIImageView())
    
    override var isSelected: Bool {
        didSet {
            icon.image = isSelected ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(container)
        container.snp.makeConstraints({ $0.edges.equalToSuperview().inset(12) })
        container.addArrangedSubviews([nameLabel, icon])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(item: MenuViewController.MenuItemRow) {
        nameLabel.text = item.menuItem.description
        isSelected = item.isSelected
    }
}

class SummaryView: UIView {
    
    var checkoutHandler: (() -> Void)?
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 12
        return $0
    }(UIStackView())
    
    private var subtotal = SectionTitle(title: "Summary", value: NumberFormatter.currency.string(for: 0))
    private var fees = SectionTitle(title: "Sales tax & fees", value: NumberFormatter.currency.string(for: 0))
    private var total = SectionTitle(title: "Total", value: NumberFormatter.currency.string(for: 0))
    
    private lazy var button: CustomButton = {
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return $0
    }(CustomButton.roundedButtonBordered(title: "Checkout",
                                         backgroundColor: .systemBackground,
                                         foregroundColor: .systemBlue,
                                         height: 44,
                                         inset: 16))
    
    init() {
        super.init(frame: .zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(container)
        container.snp.makeConstraints({ $0.edges.equalToSuperview().inset(12) })
        container.addArrangedSubviews([subtotal, fees, total, button])
    }
    
    func update(orderResponse: OrderResponse?) {
        guard let orderResponse = orderResponse else {
            subtotal.valueLabel.text = NumberFormatter.currency.string(for: 0)
            fees.valueLabel.text = NumberFormatter.currency.string(for: 0)
            total.valueLabel.text = NumberFormatter.currency.string(for: 0)
            button.isEnabled = false
            return
        }
        
        button.isEnabled = orderResponse.order.total > 0
        subtotal.valueLabel.text = orderResponse.order.subtotalString
        fees.valueLabel.text = orderResponse.order.feeAndTaxesString
        total.valueLabel.text = orderResponse.order.totalString
    }
    
    @objc private func checkoutTapped() {
        checkoutHandler?()
    }
}
