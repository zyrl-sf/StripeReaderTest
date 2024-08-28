//
//  PaymentMethod.swift
//  ZYRLPad
//
//  Created by Максим on 06.02.2024.
//  Copyright © 2024 iOS Master. All rights reserved.
//

import Foundation

enum PaymentMethod: String, Codable {
    case split = "SPLIT"
    case card = "card"
    case cash = "cash"
    case thirdParty = "THIRD_PARTY"
    case account = "ACCOUNT"
    case payLater = "Pay Later"
    
    var printingString: String {
        switch self {
        case .split:
            return "split"
        case .card:
            return "card"
        case .cash:
            return "cash"
        case .thirdParty:
            return "3rd party"
        case .account:
            return "account"
        case .payLater:
            return "pay later"
        }
    }
}
