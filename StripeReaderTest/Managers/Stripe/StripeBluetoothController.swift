//
//  StripeUpdateController.swift
//  StripeReaderTest
//
//  Created by Максим on 20.08.2024.
//

import UIKit
import StripeTerminal


class StripeBluetoothController: NSObject {
    
    var messageForUser: ((String?) -> Void)?
    
    var stripeUpdateView: StripeUpdateView?
    
}

extension StripeBluetoothController: BluetoothReaderDelegate {
    
    func reader(_ reader: Reader, didReportAvailableUpdate update: ReaderSoftwareUpdate) {
        
    }
    
    func reader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        
        let view = UIApplication.shared.keyWindow
        stripeUpdateView = StripeUpdateView(updateName: update.deviceSoftwareVersion, viewController: nil)
        stripeUpdateView?.present(view: view)
        
        var time = ""
        
        switch update.estimatedUpdateTime {
        case .estimateLessThan1Minute:
            time = "Estimate Less Than 1 Minute"
        case .estimate1To2Minutes:
            time = "Estimate 1 To 2 Minutes"
        case .estimate2To5Minutes:
            time = "Estimate 2 To 5 Minutes"
        case .estimate5To15Minutes:
            time = "Estimate 5 To 15 Minutes"
        @unknown default:
            break
        }
        
        stripeUpdateView?.update(estimateTime: time)
    }
    
    func reader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        stripeUpdateView?.update(progress: progress)
    }
    
    func reader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: (any Error)?) {
        stripeUpdateView?.dismiss()
    }
    
    // MARK: BluetoothReaderDelegate - only needed for Bluetooth readers, this is the delegate set during connectBluetoothReader
    
    func reader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
        let text = Terminal.stringFromReaderInputOptions(inputOptions)
        messageForUser?(text)
    }
    
    func reader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
        let text = Terminal.stringFromReaderDisplayMessage(displayMessage)
        messageForUser?(text)
    }
    
    // MARK: ReaderDisplayDelegate

     func terminal(_ terminal: Terminal, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
         let text = Terminal.stringFromReaderInputOptions(inputOptions)
         messageForUser?(text)
     }

     func terminal(_ terminal: Terminal, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
         let text = Terminal.stringFromReaderDisplayMessage(displayMessage)
         messageForUser?(text)
     }
}
