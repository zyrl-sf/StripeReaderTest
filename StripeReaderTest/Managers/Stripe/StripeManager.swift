//
//  StripeManager.swift
//  StripeReaderTest
//
//  Created by Максим on 20.08.2024.
//

import StripeTerminal
import UIKit

protocol StripeManagerDelegate: AnyObject {
    func isDiscovering(state: Bool)
    func discovered(readers: [Reader])
    func isConnecting(state: Bool)
    func connected(reader: Reader)
    func failed(error: Error)
}

class StripeManager: NSObject {
    
    private lazy var discovery = StripeDiscoveryController(delegate: self)
    private lazy var connection = StripeReaderConnectionController(delegate: self, 
                                                                   bluetoothDelegate: bluetoothDelegate,
                                                                   usbReaderDelegate: usbReaderDelegate)
    
    weak var connectionDelegate: StripeManagerDelegate?
    private weak var bluetoothDelegate: BluetoothReaderDelegate?
    private weak var usbReaderDelegate: UsbReaderDelegate?
    
    var isReaderConnected: Bool {
        Terminal.shared.connectedReader != nil
    }
    
    init(connectionDelegate: StripeManagerDelegate?, 
         bluetoothDelegate: BluetoothReaderDelegate?,
         usbReaderDelegate: UsbReaderDelegate?) {
        
        self.connectionDelegate = connectionDelegate
        self.bluetoothDelegate = bluetoothDelegate
        self.usbReaderDelegate = usbReaderDelegate
        super.init()
    }
    
    static func initialize(apiClient: StripeAPIClient) {
        Terminal.setTokenProvider(apiClient)
    }
    
    func startDescovery(locationId: String?) {
        
        if let reader = Terminal.shared.connectedReader {
            connected(reader: reader)
            return
        }
        
        discovery.discoverReaders()
        connectionDelegate?.isDiscovering(state: true)
    }
    
    func stopDiscovery(target: BaseViewController? = nil, completion: (() -> ())?) {
        target?.showLoading()
        discovery.discoverCancelable?.cancel({ _ in
            target?.hideLoading()
            completion?()
        })
    }
    
    func disconnectReader(target: BaseViewController? = nil, completion: (() -> ())? ) {
        guard Terminal.shared.connectedReader != nil else {
            completion?()
            return
        }
        
        target?.showLoading()
        Terminal.shared.disconnectReader { error in
            target?.hideLoading()
            if error == nil {
                
            }
            completion?()
        }
    }
    
}

extension StripeManager: StripeDiscoveryControllerDelegate {
    
    func discovered(readers: [Reader]) {
        connectionDelegate?.isDiscovering(state: false)
        connectionDelegate?.discovered(readers: readers)
        
        guard let reader = readers.first else {
            return
        }
        
        connection.connect(reader: reader)
        connectionDelegate?.isConnecting(state: true)
    }
    
    func failed(error: any Error) {
        connectionDelegate?.isDiscovering(state: false)
        connectionDelegate?.failed(error: error)
    }
}

extension StripeManager: StripeReaderConnectionDelegate {
    
    func connectionConfigurationFailed(error: any Error) {
        connectionDelegate?.isConnecting(state: false)
        connectionDelegate?.failed(error: error)
    }
    
    func connected(reader: Reader) {
        connectionDelegate?.isConnecting(state: false)
        connectionDelegate?.connected(reader: reader)
    }
    
    func connectionFailed(error: any Error) {
        connectionDelegate?.isConnecting(state: false)
        connectionDelegate?.failed(error: error)
    }
    
}


