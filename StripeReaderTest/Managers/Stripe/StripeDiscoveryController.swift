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
        switch LocalStorage.readerType {
        case .bluetooth:
            discoverBluetoothReaders()
        case .internet:
            discoverInternetReaders()
        }
    }
    
    // Action for a "Discover Readers" button
    func discoverBluetoothReaders() {
        do {
            let config = try BluetoothScanDiscoveryConfigurationBuilder()
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
    
    func discoverInternetReaders() {
        
        var location: Restaurant? { LocalStorage.restaurant }
        
        do {
            let config = try InternetDiscoveryConfigurationBuilder()
                .setLocationId(location?.stripeTerminalLocationId)
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
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        // In your app, display the discovered reader(s) to the user.
        // Call `connectBluetoothReader` after the user selects a reader to connect to.
        delegate?.discovered(readers: readers)
    }
}
