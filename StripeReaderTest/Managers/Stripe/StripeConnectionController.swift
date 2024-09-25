//
//  StripeConnectionController.swift
//  StripeReaderTest
//
//  Created by Максим on 20.08.2024.
//

import StripeTerminal

protocol StripeReaderConnectionDelegate: AnyObject {
    func connected(reader: Reader)
    func connectionConfigurationFailed(error: Error)
    func connectionFailed(error: Error)
}

class StripeReaderConnectionController: NSObject {
    
    private weak var delegate: StripeReaderConnectionDelegate?
    private weak var bluetoothDelegate: BluetoothReaderDelegate?
    private weak var usbReaderDelegate: UsbReaderDelegate?
    
    init(delegate: StripeReaderConnectionDelegate?, 
         bluetoothDelegate: BluetoothReaderDelegate?,
         usbReaderDelegate: UsbReaderDelegate?) {
        
        self.delegate = delegate
        self.bluetoothDelegate = bluetoothDelegate
        self.usbReaderDelegate = usbReaderDelegate
    }
    
    func connect(reader: Reader) {
        switch LocalStorage.readerType {
        case .bluetooth:
            connectBluetoothReader(reader: reader)
        case .internet:
            connectInternetReader(reader: reader)
        case .usb:
            connectUSBReader(reader: reader)
        }
    }
    
    func connectBluetoothReader(reader: Reader) {
        
        var location: Restaurant? { LocalStorage.restaurant }
        
        guard let bluetoothDelegate = bluetoothDelegate,
              let terminalId = location?.stripeTerminalLocationId else { return }
        
        // Call `connectBluetoothReader` with the selected reader and a connection config
        // to register to a location as set by your app.
        let connectionConfig: BluetoothConnectionConfiguration
        do {
            connectionConfig = try BluetoothConnectionConfigurationBuilder(locationId: terminalId).build()
        } catch {
            // Handle the error building the connection configuration
            delegate?.connectionConfigurationFailed(error: error)
            return
        }
        
        Terminal.shared.connectBluetoothReader(reader, delegate: bluetoothDelegate, connectionConfig: connectionConfig) { [weak self] reader, error in
            if let reader = reader {
                print("Successfully connected to reader: \(reader)")
                self?.delegate?.connected(reader: reader)
            } else if let error = error {
                print("connectBluetoothReader failed: \(error)")
                self?.delegate?.connectionFailed(error: error)
            }
        }
    }
    
    func connectUSBReader(reader: Reader) {
        
        var location: Restaurant? { LocalStorage.restaurant }
        
        guard let usbReaderDelegate = usbReaderDelegate,
              let terminalId = location?.stripeTerminalLocationId else { return }
        
        // Call `connectBluetoothReader` with the selected reader and a connection config
        // to register to a location as set by your app.
        let connectionConfig: UsbConnectionConfiguration
        do {
            connectionConfig = try UsbConnectionConfigurationBuilder(locationId: terminalId).build()
        } catch {
            // Handle the error building the connection configuration
            delegate?.connectionConfigurationFailed(error: error)
            return
        }
        
        Terminal.shared.connectUsbReader(reader, delegate: usbReaderDelegate, connectionConfig: connectionConfig) { [weak self] reader, error in
            if let reader = reader {
                print("Successfully connected to reader: \(reader)")
                self?.delegate?.connected(reader: reader)
            } else if let error = error {
                print("connectUsbReader failed: \(error)")
                self?.delegate?.connectionFailed(error: error)
            }
        }
    }
    
    func connectInternetReader(reader: Reader) {
        
        var location: Restaurant? { LocalStorage.restaurant }
        
        let connectionConfig: InternetConnectionConfiguration
        do {
            connectionConfig = try InternetConnectionConfigurationBuilder().build()
        } catch {
            // Handle the error building the connection configuration
            delegate?.connectionConfigurationFailed(error: error)
            return
        }
        
        Terminal.shared.connectInternetReader(reader, connectionConfig: connectionConfig) { [weak self] reader, error in
            if let reader = reader {
                print("Successfully connected to reader: \(reader)")
                self?.delegate?.connected(reader: reader)
            } else if let error = error {
                print("connectBluetoothReader failed: \(error)")
                self?.delegate?.connectionFailed(error: error)
            }
        }
        
    }
}
