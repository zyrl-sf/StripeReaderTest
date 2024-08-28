//
//  LocalStorage.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation


class LocalStorage {
    
    static var order: Order? {
        set(order) {
            if let encoded = try? JSONEncoder().encode(order){
                UserDefaults.standard.set(encoded, forKey: "selectedOrder")
            }
        }
        get {
            if let data = UserDefaults.standard.value(forKey: "selectedOrder") as? Data, let objectDecoded = try? JSONDecoder().decode(Order.self, from: data) as Order {
                return objectDecoded
            }
            return nil
        }
    }
    
    static var token: String? {
        set {
            switch environment {
            case .staging:
                UserDefaults.standard.set(newValue, forKey: "stagingToken")
            case .production:
                UserDefaults.standard.set(newValue, forKey: "productionToken")
            }
        }
        get {
            switch environment {
            case .staging:
                return UserDefaults.standard.string(forKey: "stagingToken")
            case .production:
                return UserDefaults.standard.string(forKey: "productionToken")
            }
        }
    }
    
    static var isStripeSimulatorEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isStripeSimulatorEnabled")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isStripeSimulatorEnabled")
        }
    }
    
    static var environment: Environment {
        get {
            guard let environment = UserDefaults.standard.value(forKey: "Environment") as? String,
                  let obj = Environment(rawValue: environment) else {
                return .staging
            }
            return obj
        }
        set(environment) {
            UserDefaults.standard.set(environment.rawValue, forKey: "Environment")
        }
    }
    
    static var restaurant: Restaurant? {
        set(restaurant) {
            
            switch environment {
            case .staging:
                if let encoded = try? JSONEncoder().encode(restaurant){
                    UserDefaults.standard.set(encoded, forKey: "selectedStagingRestaurant")
                }
            case .production:
                if let encoded = try? JSONEncoder().encode(restaurant){
                    UserDefaults.standard.set(encoded, forKey: "selectedProductionRestaurant")
                }
            }

        }
        get {
            
            switch environment {
            case .staging:
                if let data = UserDefaults.standard.value(forKey: "selectedStagingRestaurant") as? Data, let objectDecoded = try? JSONDecoder().decode(Restaurant.self, from: data) as Restaurant {
                    return objectDecoded
                }
            case .production:
                if let data = UserDefaults.standard.value(forKey: "selectedProductionRestaurant") as? Data, let objectDecoded = try? JSONDecoder().decode(Restaurant.self, from: data) as Restaurant {
                    return objectDecoded
                }
            }
           
            return nil
        }
    }
    
    static var menuItems: [MenuItem] {
        set(menuItem) {
            if let encoded = try? JSONEncoder().encode(menuItem){
                UserDefaults.standard.set(encoded, forKey: "menuItem_objs")
            }
        }
        get {
            if let objects = UserDefaults.standard.value(forKey: "menuItem_objs") as? Data, let objectsDecoded = try? JSONDecoder().decode(Array.self, from: objects) as [MenuItem] {
                return objectsDecoded
            }
            return []
        }
    }
    
    static var orderRequestType: OrderRequestType {
        get {
            guard let type = UserDefaults.standard.value(forKey: "OrderRequestType") as? String,
                  let obj = OrderRequestType(rawValue: type) else {
                return .regular
            }
            return obj
        }
        set(type) {
            UserDefaults.standard.set(type.rawValue, forKey: "OrderRequestType")
        }
    }

}

// reader
extension LocalStorage {
    
    static var readerType: StripeReaderType {
        get {
            guard let type = UserDefaults.standard.value(forKey: "StripeReaderType") as? String,
                  let obj = StripeReaderType(rawValue: type) else {
                return .bluetooth
            }
            return obj
        }
        set(type) {
            UserDefaults.standard.set(type.rawValue, forKey: "StripeReaderType")
        }
    }
    
}
