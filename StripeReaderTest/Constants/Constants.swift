//
//  Constants.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import UIKit

enum Environment: String, CaseIterable {
    case staging = "Staging"
    case production = "Production"
    
    var stripeStatus: String {
        switch self {
        case .staging:
            return "dev"
        case .production:
            return "live"
        }
    }
    
    var url: String {
        switch self {
        case .staging:
            return "https://zdash-stg.getrevi.com"
        case .production:
            return "https://zdash.zyrl.us"
        }
    }
    
    var login: String {
        switch self {
        case .staging:
            return "service+stg@getrevi.com"
        case .production:
            return "aakash@zyrl.us"
        }
    }
    
    var password: String {
        switch self {
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
    
    mutating func toggle() {
        switch self {
            case .internet:
                self = .bluetooth
            case .bluetooth:
                self = .internet
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .internet:
            return UIImage(named: "int_reader")
        case .bluetooth:
            return UIImage(named: "bt_reader")
        }
    }
}
