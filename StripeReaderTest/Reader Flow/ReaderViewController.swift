//
//  ReaderViewController.swift
//  StripeReaderTest
//
//  Created by Максим on 19.08.2024.
//

import UIKit
import StripeTerminal

class ReaderViewController: BaseViewController {
    
    var discoveryView: ReaderDiscoveryView = {
        $0.isHidden = true
        return $0
    }(ReaderDiscoveryView())
    
    var connectionView: ReaderConnectionView = {
        $0.isHidden = true
        return $0
    }(ReaderConnectionView())
    
    var successView: ReaderSuccessView = {
        $0.isHidden = true
        return $0
    }(ReaderSuccessView())
    
    var failedView: ReaderFailedView = {
        $0.isHidden = true
        return $0
    }(ReaderFailedView())
    
    private var stripeManager: StripeManager
    
    init(stripeManager: StripeManager) {
        self.stripeManager = stripeManager
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(discoveryView)
        discoveryView.snp.makeConstraints({ 
            $0.edges.equalToSuperview()
        })
        
        view.addSubview(connectionView)
        connectionView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        view.addSubview(successView)
        successView.snp.makeConstraints({ 
            $0.edges.equalToSuperview()
        })
        
        view.addSubview(failedView)
        failedView.snp.makeConstraints({ 
            $0.edges.equalToSuperview()
        })
        
        title = "Reader"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        stripeManager.connectionDelegate = self
        stripeManager.startDescovery(locationId: LocalStorage.restaurant?.id2)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stripeManager.stopDiscovery(target: nil, completion: nil)
    }
}

extension ReaderViewController: StripeManagerDelegate {
    
    func isDiscovering(state: Bool) {
        discoveryView.isHidden = !state
    }
    
    func discovered(readers: [Reader]) {
        guard !readers.isEmpty else { 
            failedView.icon.isHidden = true
            failedView.label.text = "0 readers found"
            failedView.isHidden = false
            return
        }
        let id = readers[0].serialNumber
        connectionView.readerId.text = id
        successView.readerId.text = id
        failedView.readerId.text = id
    }
    
    func isConnecting(state: Bool) {
        connectionView.isHidden = !state
    }
    
    func connected(reader: Reader) {
        successView.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = true
        nextHandler?()
    }
    
    func failed(error: any Error) {
        failedView.label.text = "Connection failed: " + error.localizedDescription
        failedView.isHidden = false
    }
}

