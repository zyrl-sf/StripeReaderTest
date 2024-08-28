//
//  SecretResponse.swift
//  ZYRLPad
//
//  Created by Maxim on 09.11.2022.
//  Copyright © 2022 iOS Master. All rights reserved.
//

import Foundation


struct ClientSecretResponse: Codable {
    
    let clientSecret: String
    
    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
    }
}
