//
//  TipRecommendations.swift
//  StripeReaderTest
//
//  Created by Максим on 26.08.2024.
//

import Foundation

struct TipRecommendations: Codable {
    
    private var defaultTipSelection: Int?
    var maxTipsCents: Int?
    var presets: [TipPreset]
    
    var tipSelectionIndex: Int? {
        guard let selection = defaultTipSelection else {
            return nil
        }
        return max(selection - 1, 0)
    }
    
    init() {
        defaultTipSelection = nil
        maxTipsCents = nil
        presets = []
    }
    
    enum CodingKeys: String, CodingKey {
        case defaultTipSelection = "default_tip_selection", maxTipsCents = "max_tips_cents", presets
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        defaultTipSelection = try container.decode(Int?.self, forKey: .defaultTipSelection)
        maxTipsCents = try? container.decode(Int?.self, forKey: .maxTipsCents)
        presets = try container.decode([TipPreset].self, forKey: .presets)
    }
    
    var toRequests: [TipsRequest] {
        presets.map({ TipsRequest(preset: $0) })
    }
}

struct TipPreset: Codable {
    var type: TipsType
    var value: Int
    var cents: Int
    
    enum CodingKeys: String, CodingKey {
        case type = "type", value, cents
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(TipsType.self, forKey: .type)
        value = try container.decode(Int.self, forKey: .value)
        cents = try container.decode(Int.self, forKey: .cents)
    }
}
