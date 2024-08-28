//
//  TipsRequest.swift
//  AdyenReaderTest
//
//  Created by Maxim on 24.05.2023.
//

import Foundation

struct TipsRequest: Codable {
    let value: Int
    let type: TipsType
    
    var nameString: String? {
        switch self.type {
        case .dollars:
            NumberFormatter.currency.string(for: Float(value)/100)
        case .percent:
            NumberFormatter.percent.string(for: Float(value)/100)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "tips"
        case type = "tips_type"
    }
    
    init(preset: TipPreset) {
        switch preset.type {
        case .dollars:
            self.value = preset.cents
            self.type = preset.type
        case .percent:
            self.value = preset.value
            self.type = preset.type
        }
    }
}

enum TipsType: String, Codable, Equatable {
    case dollars = "$"
    case percent = "%"
}
