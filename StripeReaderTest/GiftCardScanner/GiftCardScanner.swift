//
//  GiftCardScanner.swift
//  StripeReaderTest
//
//  Created by Максим on 27.09.2024.
//

import UIKit

class GiftCardScanner: BaseViewController {
    
    var scanningView = GiftcardScanningView()
    
    private let paymentController = StripePaymentController()
    
    override init() {
        super.init()
        
        view.backgroundColor = .systemBackground
        view.addSubview(scanningView)
        scanningView.snp.makeConstraints({
            $0.top.equalTo(view.snp.topMargin)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottomMargin)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startScanning()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startScanning() {
        Task {
            do {
                let string = try await paymentController.readGiftCard()
                scanningView.statusLabel.text = string
            } catch {
                scanningView.statusLabel.text = "Error: \(error.localizedDescription)"
            }
        }
    }
}

class GiftcardScanningView: UIView {
    
    private var container: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .center
        return $0
    }(UIStackView())
    
    var statusLabel: UILabel = {
        $0.text = "Scanning..."
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(container)
        container.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview().inset(40)
        })
        container.addArrangedSubviews([statusLabel])
    }
}
