//
//  RefundItem.swift
//  ZYRLPad
//
//  Created by Максим on 23.11.2023.
//  Copyright © 2023 iOS Master. All rights reserved.
//

import Foundation

struct RefundResponse: Codable {
    let refund: RefundItem
}

struct RefundItem: Codable {

    let id: String?
    let createdAt: String?
    let amountCents: Int
    let reason: String?
    let source: String?
    
    var createdString: String? {
        let date = createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'hh:mm:ss.SSSSSS") ?? createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS")
        return date?.toString(dateFormat: "MMM d, yyyy")
    }
    
    var amountFloat: Double {
        Double(amountCents)/Double(100)
    }
    
    var amountString: String? {
        NumberFormatter.currency.string(for: amountFloat)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case amountCents = "amount"
        case reason
        case source
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decode(String?.self, forKey: .id)
        createdAt = try? container.decode(String?.self, forKey: .createdAt)
        amountCents = (try? container.decode(Int?.self, forKey: .amountCents)) ?? 0
        reason = try? container.decode(String?.self, forKey: .reason)
        source = try? container.decode(String?.self, forKey: .source)
    }
}
