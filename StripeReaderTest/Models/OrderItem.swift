//
//  OrderItem.swift
//  ZYRLPad
//
//  Created by Максим on 06.02.2024.
//  Copyright © 2024 iOS Master. All rights reserved.
//

import Foundation
//
//extension OrderItem: Equatable {
//    
//    
//}

struct OrderItem: Codable {
    
    var id: Int?
    var title: String?
    var basePriceCents: Int
    var priceCents: Int
    var priceWithDiscountCents: Int
    var quantity: Int
    var modifiersString: String?
    var customerRequest: String?
    var appearsOnReceipt: Bool
    var itemTaxCents: Int
    var itemTaxDouble: Double?
    var info: OrderItemInfo?
    var category: Int?
    
    var immutableId: String?
    var kitchenStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case basePriceCents = "base_item_price"
        case priceCents = "price_cents"
        case priceWithDiscountCents = "price_with_discount"
        case quantity
        case modifiersString = "instructions"
        case customerRequest = "customer_request"
        case appearsOnReceipt = "appears_on_receipt"
        case itemTaxCents = "item_tax_cents"
        case info = "item"
        case category
        
        case immutableId = "immutable_id"
        case kitchenStatus = "kitchen_status"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decode(Int?.self, forKey: .id)
        immutableId = try? container.decode(String?.self, forKey: .immutableId)
        title = try container.decode(String?.self, forKey: .title)
        priceCents = try container.decode(Int.self, forKey: .priceCents)
        basePriceCents = try container.decode(Int.self, forKey: .basePriceCents)
        priceWithDiscountCents = try container.decode(Int.self, forKey: .priceWithDiscountCents)
        quantity = try container.decode(Int.self, forKey: .quantity)
        modifiersString = try container.decode(String?.self, forKey: .modifiersString)
        customerRequest = try container.decode(String?.self, forKey: .customerRequest)
        appearsOnReceipt = (try? container.decode(Bool.self, forKey: .appearsOnReceipt)) ?? true
        itemTaxCents = try container.decode(Int.self, forKey: .itemTaxCents)
        info = try? container.decode(OrderItemInfo?.self, forKey: .info)
        category = try? container.decode(Int?.self, forKey: .category)
        kitchenStatus = try? container.decode(String?.self, forKey: .kitchenStatus)
    }

}

extension OrderItem {
    
    var basePrice: Double {
        return Double(basePriceCents) / 100
    }
    
    var basePriceString: String? {
        return NumberFormatter.currency.string(for: basePrice)
    }
    
    var price: Double {
        return Double(priceCents) / 100
    }
    
    var priceString: String? {
        NumberFormatter.currency.string(for: price)
    }
    
    var priceWithDiscount: Float {
        return Float(priceWithDiscountCents) / 100
    }
    
    var itemTax: Double {
        return itemTaxDouble ?? Double(itemTaxCents) / 100
    }
    
    var priceStringToShow: String {
        let price = (Double(priceWithDiscountCents) + Double(itemTaxCents) / Double(quantity)) / 100
        return NumberFormatter.currency.string(for: price) ?? ""
    }
    
}

struct OrderItemInfo: Codable, Equatable {
    let id: Int
    let description: String?
    let isCustom: Bool?
    let specialItem: String?
    
    enum CodingKeys: String, CodingKey {
        case id, 
             description,
             isCustom = "is_custom",
             specialItem = "special_item"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        description = try? container.decode(String?.self, forKey: .description)
        isCustom = try? container.decode(Bool?.self, forKey: .isCustom)
        specialItem = try container.decode(String?.self, forKey: .specialItem)
    }
    
    var idString: String {
        "\(id)"
    }
}
