//
//  OrderHistoryController.swift
//  StripeReaderTest
//
//  Created by Максим on 27.08.2024.
//

import UIKit


class OrderHistoryController: BaseViewController {
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 12
        return $0
    }(UIStackView())
    
    private lazy var tableView: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.register(OrderHistoryCell.self, forCellReuseIdentifier: "cell")
        return $0
    }(UITableView())
    
    var orders = [Order]()
    
    override init() {
        super.init()
        
        title = "Order History"
        
        view.addSubview(container)
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            container.snp.makeConstraints({
                $0.top.equalTo(view.snp.topMargin)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(UIScreen.main.bounds.width/2)
                $0.bottom.equalTo(view.snp.bottomMargin)
            })
        } else {
            container.snp.makeConstraints({
                $0.top.equalTo(view.snp.topMargin)
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(view.snp.bottomMargin)
            })
        }
        
        container.addArrangedSubviews([tableView])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPastOrders()
    }
    
    private func fetchPastOrders() {
        
        guard let uuid = LocalStorage.restaurant?.uuid else { return }
        let hours = max(Calendar.current.component(.hour, from: Date()), 1)
        
        Task {
            do {
                showLoading()
                let orders: [Order] = try await APIManager.fetchPastOrders(locationUUID: uuid, hours: hours).makeRequest()
                self.orders = orders
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                hideLoading()
            } catch {
                hideLoading()
                showAlert(message: error.localizedDescription)
            }
        }
    }
}

extension OrderHistoryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderHistoryCell
        cell.update(item: orders[indexPath.row])
        return cell
    }
    
}

extension OrderHistoryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let order = orders[indexPath.row]
    }
}


class OrderHistoryCell: UITableViewCell {
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 4
        return $0
    }(UIStackView())
    
    private var dateLabel = SectionTitle(title: "Created at", value: nil)
    private var orderNumberLabel = SectionTitle(title: "Order number", value: nil)
    private var paymentStatusLabel = SectionTitle(title: "Payment status", value: nil)
    private var subtotalLabel = SectionTitle(title: "Subtotal", value: nil)
    private var serviceFeeLabel = SectionTitle(title: "Service fee", value: nil)
    private var taxesLabel = SectionTitle(title: "Taxes", value: nil)
    private var tipsLabel = SectionTitle(title: "Tips", value: nil)
    private var totalLabel = SectionTitle(title: "Total", value: nil)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(container)
        container.snp.makeConstraints({ $0.edges.equalToSuperview().inset(12) })
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(item: Order) {
        container.removeArrangedSubviews()
        container.addArrangedSubviews([paymentStatusLabel
                                      ])
        
        paymentStatusLabel.nameLabel.text = item.createdAtString
        paymentStatusLabel.valueLabel.text = [item.orderNumberString, item.paymentStatus?.string].compactMap({ $0 }).joined(separator: " - ")
        
        item.items.forEach({ item in
            let s = FoodSection(title: item.title, value: item.priceString, color: .systemGray)
            container.addArrangedSubview(s)
        })
        
        container.addArrangedSubview(FoodSection(title: "Subtotal", value: item.subtotalString))
        container.addArrangedSubview(FoodSection(title: "Service fee", value: ["+", item.serviceFeeString].compactMap({ $0 }).joined()))
        container.addArrangedSubview(FoodSection(title: "Taxes", value: ["+", item.taxesString].compactMap({ $0 }).joined()))
        container.addArrangedSubview(FoodSection(title: "Tips", value: ["+", item.tipsString].compactMap({ $0 }).joined()))
        container.addArrangedSubview(FoodSection(title: "Total", value: item.totalString))
    }
}
