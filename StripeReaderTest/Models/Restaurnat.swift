//
//  Restaurnat.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import Foundation


class Restaurant: Codable {
    var id: Int
    var name: String?
    var id2: String?
    var uuid: String?
    var stripeTerminalLocationId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case id2
        case uuid
        case stripeTerminalLocationId = "stripe_terminal_location_id"
    }
}
