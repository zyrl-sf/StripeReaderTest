//
//  Logger.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

class Logger {
    
    static func request(request: String, headers: [String: Any] = [:], params: [String: Any?]) -> String? {
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            let message = "\nHTTP request: \(request)\nHeaders: \(headers)\nParams: \(jsonString)\n"
           // print(message)
            FeedCoordinator.currentConsole?.pushLogs(message: message)
            return message
        }
        return nil
    }
    
    static func response(request: String, data: Data?) -> String? {
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            let message = "\nHTTP response: \(request)\nParams: \(jsonString)\n"
           // print(message)
            FeedCoordinator.currentConsole?.pushLogs(message: message)
            return message
        }
        return nil
    }
    
}
