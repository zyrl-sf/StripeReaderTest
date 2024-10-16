//
//  Constants.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import UIKit

enum Environment: String, CaseIterable {
    case metallica = "Metallica"
    case staging = "Staging"
    case production = "Production"
    
    var stripeStatus: String {
        switch self {
        case .metallica:
            return "dev"
        case .staging:
            return "dev"
        case .production:
            return "live"
        }
    }
    
    var url: String {
        switch self {
        case .metallica:
            return "https://zdash-stg.getrevi.com"
        case .staging:
            return "https://zdash-stg.getrevi.com"
        case .production:
            return "https://zdash.zyrl.us"
        }
    }
    
    var login: String {
        switch self {
        case .metallica:
            return "akash_1993tyagi@yahoo.co.in"
        case .staging:
            return "service+stg@getrevi.com"
        case .production:
            return "aakash@zyrl.us"
        }
    }
    
    var password: String {
        switch self {
        case .metallica:
            return "thestagingpassword"
        case .staging:
            return "thestagingpassword"
        case .production:
            return "IwonttellYOU"
        }
    }
}

enum StripeReaderType: String {
    case internet = "Internet"
    case bluetooth = "Bluetooth"
    case usb = "USB"
    
    mutating func toggle() {
        switch self {
            case .internet:
                self = .bluetooth
            case .bluetooth:
                self = .usb
            case .usb:
                self = .internet
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .internet:
            return UIImage(named: "int_reader")
        case .bluetooth, .usb:
            return UIImage(named: "bt_reader")
        }
    }
}
