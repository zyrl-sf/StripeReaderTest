//
//  OrderResponse.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import UIKit

struct OrderResponse: Codable {
    var order: Order
    
    enum CodingKeys: String, CodingKey {
        case order
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        order = try container.decode(Order.self, forKey: .order)
    }
}


enum PaymentStatus: String, Codable {
    case paid = "PAID"
    case unpaid = "UNPAID"
    case payLater = "PAY_LATER"
    
    var string: String {
        switch self {
        case .paid:
            return "Paid 🟢"
        case .unpaid:
            return "Unpaid 🔴"
        case .payLater:
            return "Pay later 🟠"
        }
    }
}

struct Order: Codable {
    //common
    var id2: String
    var uuid: String
    var subtotalCents: Int
    var serviceFeeCents: Int
    var taxesCents: Int
    var discountAmountCents: Int
    var tipsCents: Int
    var totalCents: Int
    var loyaltyAmountCents: Int
    var lines: [OrderItem]
    var paymentStatus: PaymentStatus?
    var createdAt: String?
    var updatedAt: String?
    var orderNumber: String?
    var refundAmountCents: Int
    var orderFor: String?
    var refundResponse: [RefundResponse]
    var tableNumber: String?
    var nonFoodInstructions: String?
    
    //order
    var discountMessage: String
    var transactionId: String?
    
    //past order
    var paymentMethod: PaymentMethod?
    var tpProviderId: String?
    var promocode: String?
    var cashReceiveCents: Int?
    var cashChangeCents: Int?
    var cancellationReason: String?
    var state: Int
    var stateName: String?
    var pickupTime: String?
    var giftCardPaidCents: Int
    var giftCardRefundCents: Int
    
    enum CodingKeys: String, CodingKey {
        
        //common
        case  uuid
        case  id2
        case  subtotalCents = "subtotal_cents"
        case  serviceFeeCents = "service_fee_cents"
        case  taxesCents = "taxes_cents"
        case  discountAmountCents = "discount_amount_cents"
        case  tipsCents = "tips_cents"
        case  totalCents = "total_cents"
        case  loyaltyAmountCents = "loyalty_amount_cents"
        case  lines
        case  paymentStatus = "payment_status"
        case  createdAt = "created_at"
        case  updatedAt = "updated_at"
        case  orderNumber = "order_number"
        case  refundAmountCents = "refund_amount_cents"
        case  orderFor = "order_for"
        case  refundResponse = "refunds"
        case  tableNumber = "table_number"
        case  nonFoodInstructions = "non_food_instructions"
        
        //order
        case  discountMessage = "discount_message"
        case  transactionId = "transaction_id"
        
        //past order
        case paymentMethod = "payment_method"
        case tpProviderId = "tp_provider_id"
        case promocode = "discount"
        case cashReceiveCents = "customer_gives_cents"
        case cashChangeCents = "customer_gets_back_cents"
        case cancellationReason = "cancellation_reason"
        case state = "state"
        case stateName = "state_name"
        case pickupTime = "pickup_time"
        case giftCardPaidCents = "gift_card_paid_cents"
        case giftCardRefundCents = "gift_card_refund_cents"
    }
    
    var items: [OrderItem] {
        lines
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //common
        id2 = (try container.decode(String?.self, forKey: .id2)) ?? ""
        uuid = (try container.decode(String?.self, forKey: .uuid)) ?? ""
        subtotalCents = try container.decode(Int.self, forKey: .subtotalCents)
        serviceFeeCents = try container.decode(Int.self, forKey: .serviceFeeCents)
        taxesCents = try container.decode(Int.self, forKey: .taxesCents)
        discountAmountCents = try container.decode(Int.self, forKey: .discountAmountCents)
        tipsCents = try container.decode(Int.self, forKey: .tipsCents)
        totalCents = try container.decode(Int.self, forKey: .totalCents)
        loyaltyAmountCents = try container.decode(Int.self, forKey: .loyaltyAmountCents)
        lines = try container.decode([OrderItem].self, forKey: .lines)
        paymentStatus = try container.decode(PaymentStatus?.self, forKey: .paymentStatus)
        createdAt = try container.decode(String?.self, forKey: .createdAt)
        updatedAt = try? container.decode(String?.self, forKey: .updatedAt)
        orderNumber = try container.decode(String?.self, forKey: .orderNumber)
        refundAmountCents = (try? container.decode(Int?.self, forKey: .refundAmountCents)) ?? 0
        orderFor = (try? container.decode(String?.self, forKey: .orderFor))?.uppercased()
        refundResponse = (try? container.decode([RefundResponse]?.self, forKey: .refundResponse)) ?? []
        tableNumber = try? container.decode(String?.self, forKey: .tableNumber)
        nonFoodInstructions = try? container.decode(String?.self, forKey: .nonFoodInstructions)
        
        //order
        discountMessage = try container.decode(String.self, forKey: .discountMessage)
        transactionId = try container.decode(String?.self, forKey: .transactionId)
        
        //past order
        paymentMethod = try container.decode(PaymentMethod?.self, forKey: .paymentMethod)
        tpProviderId = try? container.decode(String?.self, forKey: .tpProviderId)
        promocode = try? container.decode(String?.self, forKey: .promocode)
        cashReceiveCents = try? container.decode(Int?.self, forKey: .cashReceiveCents)
        cashChangeCents = try? container.decode(Int?.self, forKey: .cashChangeCents)
        cancellationReason = try? container.decode(String?.self, forKey: .cancellationReason)
        state = try container.decode(Int.self, forKey: .state)
        stateName = try container.decode(String?.self, forKey: .stateName)
        pickupTime = try? container.decode(String?.self, forKey: .pickupTime)
        giftCardPaidCents = (try? container.decode(Int?.self, forKey: .giftCardPaidCents)) ?? 0
        giftCardRefundCents = (try? container.decode(Int?.self, forKey: .giftCardRefundCents)) ?? 0
        //   items = try container.decode([OrderItem].self, forKey: .items)
    }
    
    init(dict: [String: Any]) throws {
        let object = try DictionaryDecoder().decode(Self.self, from: dict)
        
        //common
        id2 = object.id2
        uuid = object.uuid
        subtotalCents = object.subtotalCents
        serviceFeeCents = object.serviceFeeCents
        taxesCents = object.taxesCents
        discountAmountCents = object.discountAmountCents
        tipsCents = object.tipsCents
        totalCents = object.totalCents
        loyaltyAmountCents = object.loyaltyAmountCents
        lines = object.lines
        paymentStatus = object.paymentStatus
        createdAt = object.createdAt
        orderNumber = object.orderNumber
        refundAmountCents = object.refundAmountCents
        orderFor = object.orderFor
        refundResponse = object.refundResponse
        tableNumber = object.tableNumber
        nonFoodInstructions = object.nonFoodInstructions
        
        //order
        discountMessage = object.discountMessage
        transactionId = object.transactionId
        
        //past order
        paymentMethod = object.paymentMethod
        tpProviderId = object.tpProviderId
        promocode = object.promocode
        cashReceiveCents = object.cashReceiveCents
        cashChangeCents = object.cashChangeCents
        cancellationReason = object.cancellationReason
        state = object.state
        stateName = object.stateName
        pickupTime = object.pickupTime
        giftCardPaidCents = object.giftCardPaidCents
        giftCardRefundCents = object.giftCardRefundCents
    }
    
}

extension Order {
    var orderNumberString: String? {
        orderNumber.map({ "#\($0)" })
    }
}

extension Order {
    
    var isCancelled: Bool {
        stateName == "CANCELLED"
    }
    
    var flatLines: [OrderItem] {
        
        var result = [OrderItem]()
        
        lines.forEach({ line in
            let quantity = line.quantity
            var copy = line
            copy.quantity = 1
            let flat = Array(repeating: copy, count: quantity)
            result.append(contentsOf: flat)
        })
        
        return result
    }
    
}

//total
extension Order {
    var total: Double {
        return Double(totalCents) / 100
    }
    
    var totalString: String? {
        NumberFormatter.currency.string(for: total)
    }
}

//subtotal
extension Order {
    var subtotal: Double {
        return Double(subtotalCents) / 100
    }
    
    var subtotalString: String? {
        NumberFormatter.currency.string(for: subtotal)
    }
}

//promocode
extension Order {
    
    var promocodeAmount: Double {
        return Double(discountAmountCents) / 100
    }
    
    var promocodeAmountString: String? {
        NumberFormatter.currency.string(for: promocodeAmount)
    }
    
    var promocodeAmountNegativeString: String? {
        NumberFormatter.currency.string(for: -promocodeAmount)
    }
}
//loyalty
extension Order {
    var loyaltyAmount: Float {
        return Float(loyaltyAmountCents) / 100
    }
    
    var loyaltyAmountString: String? {
        NumberFormatter.currency.string(for: loyaltyAmount)
    }
}

//taxes
extension Order {
    var taxes: Double {
        return Double(taxesCents) / 100
    }
    
    var taxesString: String? {
        NumberFormatter.currency.string(for: taxes)
    }
}

//created
extension Order {
    var createdDate: Date? {
        return createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'hh:mm:ss.SSSSSS") ?? createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS")
    }
    
    var createdAtString: String {
        return createdDate?.toString(dateFormat: "M/dd/yyyy h:mm a") ?? ""
    }
    
    var createdAtDateString: String {
        return createdDate?.toString(dateFormat: "MMM d, yyyy") ?? ""
    }
    
    var createdAtTimeString: String {
        return createdDate?.toString(dateFormat: "h:mm a") ?? ""
    }
}

// tips
extension Order {
    var tips: Double {
        return Double(tipsCents) / 100
    }
    
    var tipsString: String? {
        return NumberFormatter.currency.string(for: tips)
    }
}

// fee
extension Order {
    var serviceFee: Double {
        return Double(serviceFeeCents) / 100
    }
    
    var serviceFeeString: String? {
        return NumberFormatter.currency.string(for: serviceFee)
    }
    
    var feeAndTaxes: Double {
        serviceFee + taxes
    }
    
    var feeAndTaxesString: String? {
        NumberFormatter.currency.string(for: feeAndTaxes)
    }
}

//gift card
extension Order {
    var giftCardDiscount: Double {
        Double(giftCardPaidCents)/100 - Double(giftCardRefundCents)/100
    }
    
    var giftCardDiscountString: String? {
        NumberFormatter.currency.string(for: giftCardDiscount)
    }
}

//cash payment
extension Order {
    
    var totalForCash: Double {
        total - serviceFee
    }
    
    var totalCashString: String? {
        NumberFormatter.currency.string(for: totalForCash)
    }
}

//refund
extension Order {
    
    var refunds: [RefundItem] {
        refundResponse.map({ $0.refund })
    }
    
    var refundAmount: Double {
        return Double(refundAmountCents) / 100
    }
    
    //    var refundAmountString: String? {
    //        NumberFormatter.currency.string(for: refundAmount)
    //    }
    //
    var refundString: String? {
        guard refundAmount > 0 else { return nil }
        let result = NumberFormatter.currency.string(for: refundAmount)
        return result == "" ? nil : result
    }
    
    var maxToRefund: Double {
        total - refundAmount
    }
    
    var isActive: Bool {
        stateName != "COMPLETED"
    }
}


