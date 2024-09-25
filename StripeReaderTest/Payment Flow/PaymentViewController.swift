//
//  PaymentViewController.swift
//  StripeReaderTest
//
//  Created by Максим on 21.08.2024.
//

import UIKit
import StripeTerminal

class PaymentViewController: BaseViewController {
    
    var showAlert: ((String?) -> Void)?
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 120
        return $0
    }(UIStackView())
    
    private var priceLabel: UILabel = {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 36, weight: .bold)
        return $0
    }(UILabel())
    
    private var statusLabel: UILabel = {
        $0.text = "Processing payment..."
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private lazy var successView: SuccessView = {
        $0.isHidden = true
        $0.menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        return $0
    }(SuccessView())
    
    private let paymentController = StripePaymentController()
    private var cancellable: Cancelable?
    
    init(orderRequest: OrderRequest?, orderResponse: OrderResponse?) {
        super.init()
        
        priceLabel.text = orderResponse?.order.totalString
        
        modalPresentationStyle = .formSheet
        
        view.addSubview(container)
        container.snp.makeConstraints({ $0.left.right.centerY.equalToSuperview() })
        container.addArrangedSubviews([priceLabel, statusLabel])
        
        view.addSubview(successView)
        successView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        paymentController.makePayment(
            target: self,
            sourceView: statusLabel,
            request: orderRequest,
            isLoading: { [weak self] state in
                self?.showLoading(state: state)
            }, status: { [weak self] text in
                DispatchQueue.main.async {
                    self?.statusLabel.text = text
                }
            }, cancel: { [weak self] cancellable in
                self?.cancellable = cancellable
            }, updatedTotal: { [weak self] totalString in
                DispatchQueue.main.async {
                    self?.priceLabel.text = totalString
                }
            }, completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let order):
                        self?.successView.update(order: order)
                        self?.successView.isHidden = false
                    case .failure(let error):
                        if (error as NSError).code != 2020 {
                            self?.statusLabel.textColor = .systemRed
                            self?.statusLabel.text = error.localizedDescription
                            self?.showAlert(message: error.localizedDescription)
                        }
                    }
                }
            })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if cancellable?.completed == false {
            cancellable?.cancel({ error in
//                if let error = error {
//                    let text = "Cancelling payment failed" + error.localizedDescription
//                    self?.showAlert?(text)
//                }
            })
        }
        self.nextHandler?()
    }
    
    func showUserMessage(text: String?) {
        DispatchQueue.main.async {
            self.statusLabel.text = text
        }
    }
    
    @objc private func menuTapped() {
        dismiss(animated: true)
    }
}


class SuccessView: UIView {
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 44
        $0.alignment = .center
        return $0
    }(UIStackView())
    
    private var icon: UIImageView = {
        $0.snp.makeConstraints({ $0.size.equalTo(CGSize(width: 120, height: 120)) })
        $0.image = UIImage(systemName: "checkmark.seal.fill")
        $0.tintColor = .systemGreen
        return $0
    }(UIImageView())
    
    var statusLabel: UILabel = {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.text = "Order payment succeess"
        return $0
    }(UILabel())
    
    lazy var menuButton: CustomButton = {
        return $0
    }(CustomButton.roundedButtonBordered(title: "Go back to menu",
                                         backgroundColor: .systemBackground,
                                         foregroundColor: .systemBlue,
                                         height: 44,
                                         inset: 16))
    
    init() {
        super.init(frame: .zero)
        configureViews()
        
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(container)
        container.snp.makeConstraints({ 
            $0.left.right.equalToSuperview().inset(60)
            $0.centerY.equalToSuperview()
        })
        container.addArrangedSubviews([icon, statusLabel, menuButton])
    }
    
    func update(order: Order?) {
        statusLabel.text = "Order \(order?.orderNumber ?? "nil") has been paid!"
    }
}
