//
//  String.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import Foundation

extension Optional where Wrapped == String {

    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }

}

extension String {
    
    func toDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)
    }
    
    func toDateString(inputFormat: String, outputFormat: String) -> String? {
        let date = toDate(dateFormat: inputFormat)
        return date?.toString(dateFormat: outputFormat)
    }
    
    var floatValue: Float? {
        return NumberFormatter.currency.number(from: self)?.floatValue
    }
    
    func utcToLocal(dateFormat: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = dateFormat
        
            return dateFormatter.string(from: date)
        }
        return nil
    }

}
