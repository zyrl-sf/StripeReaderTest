//
//  APIManager.swift
//  AdyenReaderTest
//
//  Created by Maxim on 09.03.2023.
//

import Foundation

struct VoidResult: Codable { }

enum APIManager {
    
    case refreshToken(login: String, password: String)
    case auth
    case fetchLocation(id: Int)
    case fetchMenuItems(locationId2: String)
    case calculateOrder(request: OrderRequest)
    case pushOrder(request: OrderRequest)
    case requestPaymentIntent(orderUUID: String)
    case captureStripePayment(stripeId: String)
    case fetchTipsRecommendation(orderUUID: String)
    case updateTips(orderUUID: String, request: TipsRequest)
    case checkStripePayment(orderUUID: String)
    case fetchPastOrders(locationUUID: String, hours: Int)
    
    var baseURL: String {
        return LocalStorage.environment.url
    }
    
    var token: String {
        return LocalStorage.token ?? ""
    }
    
    var stripeStatus: String {
        return LocalStorage.environment.stripeStatus
    }
    
    var method: String {
        switch self {
        case .auth:
            return "/auth/partner/me/"
        case .refreshToken:
            return "/auth/partner/login/"
        case .fetchLocation(id: let id):
            return "/api/business/\(id)/"
        case .fetchMenuItems(let locationId2):
            return "/menu/\(locationId2)/"
        case .calculateOrder:
            return "/api/orders/calculate/"
        case .pushOrder:
            return "/api/orders/"
        case .fetchTipsRecommendation(orderUUID: let orderUUID):
            return "/api/orders/\(orderUUID)/tip/recommendations/"
        case .updateTips(let orderUUID, _):
            return "/api/orders/\(orderUUID)/tip/"
        case .requestPaymentIntent(orderUUID: let orderUUID):
            return "/api/orders/\(orderUUID)/pay/stripe-card-present/"
        case .captureStripePayment(let stripeId):
            return "/kiosk-payment-capture/\(stripeId)/"
        case .checkStripePayment(let orderUUID):
            return "/api/orders/\(orderUUID)/pay/stripe/check/"
        case .fetchPastOrders:
            return "/api/orders/"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .auth:
            return .get
        case .refreshToken:
            return .post
        case .fetchMenuItems:
            return .get
        case .updateTips:
            return .post
        case .calculateOrder:
            return .post
        case .fetchLocation:
            return .get
        case .requestPaymentIntent:
            return .post
        case .captureStripePayment:
            return .get
        case .pushOrder:
            return .post
        case .fetchTipsRecommendation:
            return .get
        case .fetchPastOrders:
            return .get
        case .checkStripePayment(orderUUID: let orderUUID):
            return .post
        }
    }
    
    var params: [String: Any] {
        
        switch self {
        case .auth:
            return [:]
        case .refreshToken(let login, let password):
            return ["password": "\(password)", "username": "\(login)", "to": "REVIPAD"]
        case .fetchMenuItems:
            return [:]
        case .updateTips(_, let request):
            return request.dictionary ?? [:]
        case .calculateOrder(request: let request):
            return request.orderRequest
        case .fetchLocation:
            return [:]
        case .requestPaymentIntent(orderUUID: let orderUUID):
            return [
                "status": stripeStatus,
                "order_uuid": orderUUID,
                "source": 2
            ]
        case .captureStripePayment:
            return [:]
        case .pushOrder(request: let request):
            return request.orderRequest
        case .fetchTipsRecommendation:
            return [:]
        case .fetchPastOrders:
            return [:]
        case .checkStripePayment(orderUUID: let orderUUID):
            return [:]
        }
    }
    
    var body: Data? {
        switch self {
        default:
            return nil
        }
    }
    
    var query: [(String, String)] {
        switch self {
        case .auth:
            return [("expand", "businesses"),]
         //   return [("expand", "businesses"), ("expand", "permissions")]
        case .refreshToken:
            return []
        case .fetchMenuItems:
            return [("fields[]", "menu"),
                    ("fields[]", "items")]
        case .updateTips:
            return []
        case .calculateOrder:
            return []
        case .fetchLocation:
            return []
        case .requestPaymentIntent:
            return []
        case .captureStripePayment:
            return [("status", stripeStatus)]
        case .pushOrder:
            return []
        case .fetchTipsRecommendation(orderUUID: let orderUUID):
            return []
        case .fetchPastOrders(let locationUUID, let hours):
            return [("business", locationUUID),
                    ("expand", "payment_info"),
                    ("include_third_party", "true"),
                    ("expand", "tableNumber"),
                    ("expand", "third_party"),
                    ("order_by", "-created_at"),
                    ("hours", "\(hours)")]
        case .checkStripePayment(orderUUID: let orderUUID):
            return []
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .refreshToken:
            return ["Content-Type": "application/json"]
        default:
            return ["Content-Type": "application/json",
                    "Authorization": "Token \(token)",
                    "User-Agent": "ZYRLPad/2023.06.89.4 iOS/16.3.1"]
        }
    }
    
    func makeRequest<T: Codable>(logsHandler: ((String?) -> ())? = nil) async throws -> T {
        
        let urlPath = baseURL + method
        var urlComponents = URLComponents(string: urlPath)
        urlComponents?.queryItems = query.compactMap({ URLQueryItem(name: $0.0, value: $0.1) })
        
        guard let url = urlComponents?.url else {
            throw NetworkAuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        headers.forEach({
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        })
        
        if httpMethod == .post {
            let jsonData = body ?? (try? JSONSerialization.data(withJSONObject: params))
            request.httpBody = jsonData
        }
        
        let requestLog = Logger.request(request: url.absoluteString, headers: headers, params: params)
        logsHandler?(requestLog)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let responseLog = Logger.response(request: url.absoluteString, data: data)
        logsHandler?(responseLog)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode - 200 < 99 {
                
             //   print(httpResponse.statusCode)
                
                var sourceData = data
                
                if sourceData.isEmpty == true {
                    sourceData = "{}".data(using: .utf8)!
                }
                
                if let responseString = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? String {
                    if let stringData = responseString.data(using: .utf8) {
                        sourceData = stringData
                    } else {
                        throw NetworkAuthError.customError("Invalid Response from server")
                    }
                }
                
                let info = try JSONDecoder().decode(T.self, from: sourceData)
                return info
                
            } else {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let string = json?["status"] as? String, let status = StatusMessage(rawValue: string) {
                    throw status
                }
                
                if let detail = json?["detail"] as? String {
                    throw NetworkAuthError.customError(detail)
                } else {
                    let message = json.map({ "\($0)" }) ?? "Empty"
                    throw NetworkAuthError.customError(message)
                }
            }
        } else {
            throw NetworkAuthError.invalidResponse
        }
    }
    
    func getData(logsHandler: ((String?) -> ())? = nil) async throws -> Data {
        
        let urlPath = baseURL + method
        var urlComponents = URLComponents(string: urlPath)
        urlComponents?.queryItems = query.compactMap({ URLQueryItem(name: $0.0, value: $0.1) })
        
        guard let url = urlComponents?.url else {
            throw NetworkAuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        headers.forEach({
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        })
        
        if httpMethod == .post {
            let jsonData = body ?? (try? JSONSerialization.data(withJSONObject: params))
            request.httpBody = jsonData
        }
        
        let requestLog = Logger.request(request: url.absoluteString, headers: headers, params: params)
        logsHandler?(requestLog)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let responseLog = Logger.response(request: url.absoluteString, data: data)
        logsHandler?(responseLog)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode - 200 < 99 {
                
                return data
                
            } else {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let string = json?["status"] as? String, let status = StatusMessage(rawValue: string) {
                    throw status
                }
                
                if let detail = json?["detail"] as? String {
                    throw NetworkAuthError.customError(detail)
                } else {
                    let message = json.map({ "\($0)" }) ?? "Empty"
                    throw NetworkAuthError.customError(message)
                }
            }
        } else {
            throw NetworkAuthError.invalidResponse
        }
    }
}

enum NetworkAuthError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case customError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString(
                "Invalid URL",
                comment: ""
            )
        case .invalidResponse:
            return NSLocalizedString(
                "Invalid Response",
                comment: ""
            )
        case .customError(let message):
            return NSLocalizedString(
                "\(message)",
                comment: ""
            )
        }
    }
}

enum StatusMessage: String, Error {
    case Aborted
    case InProgress
    case NotFound
    case Cancel
    case Busy
    case RequiresCapture
    
    var title: String {
        switch self {
        case .Aborted:
            return "Aborted"
        case .InProgress:
            return "In Progress"
        case .NotFound:
            return "Not Found"
        case .Cancel:
            return "Canceled"
        case .Busy:
            return "Busy"
        case .RequiresCapture:
            return "RequiresCapture"
        }
    }
}

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}
