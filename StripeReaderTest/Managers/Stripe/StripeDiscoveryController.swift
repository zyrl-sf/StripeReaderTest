//
//  StripeDiscoveryController.swift
//  StripeReaderTest
//
//  Created by Максим on 20.08.2024.
//

import StripeTerminal

protocol StripeDiscoveryControllerDelegate: AnyObject {
    func discovered(readers: [Reader])
    func failed(error: Error)
}

class StripeDiscoveryController: NSObject, DiscoveryDelegate {

    var discoverCancelable: Cancelable?
    private weak var delegate: StripeDiscoveryControllerDelegate?
    
    init(delegate: StripeDiscoveryControllerDelegate? = nil) {
        self.delegate = delegate
    }
    
    func discoverReaders() {
        
        var location: Restaurant? { LocalStorage.restaurant }
        Task {
            do {
                switch LocalStorage.readerType {
                case .bluetooth:
                    try await discoverBluetoothReaders()
                case .internet:
                    try await discoverInternetReaders(stripeTerminalLocationId: location?.stripeTerminalLocationId)
                case .usb:
                    discoverUSBReaders()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // Action for a "Discover Readers" button
//    func discoverBluetoothReaders() {
//        do {
//            let config = try BluetoothScanDiscoveryConfigurationBuilder()
//                .setSimulated(LocalStorage.isStripeSimulatorEnabled)
//                .build()
//            self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: self) { [weak self] error in
//                if let error = error {
//                    print("discoverReaders failed: \(error)")
//                    self?.delegate?.failed(error: error)
//                } else {
//                    print("discoverReaders succeeded")
//                }
//            }
//        } catch {
//            delegate?.failed(error: error)
//        }
//    }
    
    func discoverUSBReaders() {
        do {
            let config = try UsbDiscoveryConfigurationBuilder()
                .setSimulated(LocalStorage.isStripeSimulatorEnabled)
                .build()
            self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: self) { [weak self] error in
                if let error = error {
                    print("discoverReaders failed: \(error)")
                    self?.delegate?.failed(error: error)
                } else {
                    print("discoverReaders succeeded")
                }
            }
        } catch {
            delegate?.failed(error: error)
        }
    }
    
//    func discoverInternetReaders() {
//        
//        var location: Restaurant? { LocalStorage.restaurant }
//        
//        do {
//            let config = try InternetDiscoveryConfigurationBuilder()
//                .setLocationId(location?.stripeTerminalLocationId)
//                .build()
//            self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: self) { [weak self] error in
//                if let error = error {
//                    print("discoverReaders failed: \(error)")
//                    self?.delegate?.failed(error: error)
//                } else {
//                    print("discoverReaders succeeded")
//                }
//            }
//        } catch {
//            delegate?.failed(error: error)
//        }
//    }
    
    func discoverBluetoothReaders() async throws {
        let config = try BluetoothScanDiscoveryConfigurationBuilder()
            .setSimulated(LocalStorage.isStripeSimulatorEnabled)
            .build()
        try await discover(config: config)
    }
    
    func discoverInternetReaders(stripeTerminalLocationId: String?) async throws {
        guard let stripeTerminalLocationId else { return }
        let config = try InternetDiscoveryConfigurationBuilder()
            .setLocationId(stripeTerminalLocationId)
            .build()
        try await discover(config: config)
    }
    
    private func discover(config: any DiscoveryConfiguration) async throws {
        try await discoverReaders(config: config,
                                  delegate: self,
                                  cancel: { _ in  })
    }
    
    private func discoverReaders(config: any DiscoveryConfiguration,
                                 delegate: any DiscoveryDelegate,
                                 cancel: ((Cancelable?) -> Void)?) async throws -> Void {
        
        return try await withCheckedThrowingContinuation { continuation in
            let cancelable = Terminal.shared.discoverReaders(config, delegate: delegate) { error in
                if let error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume(with: .success(Void()))
                }
            }
            cancel?(cancelable)
        }
    }
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        // In your app, display the discovered reader(s) to the user.
        // Call `connectBluetoothReader` after the user selects a reader to connect to.
        delegate?.discovered(readers: readers)
    }
}
