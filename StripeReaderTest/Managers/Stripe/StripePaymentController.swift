//
//  StripePaymentController.swift
//  StripeReaderTest
//
//  Created by Максим on 20.08.2024.
//

import StripeTerminal
import UIKit

class StripePaymentController: NSObject {
    
    func makePayment(target: BaseViewController?,
                     sourceView: UIView,
                     request: OrderRequest?,
                     isLoading: ((Bool) -> Void)?,
                     status: ((String) -> Void)?,
                     cancel: ((Cancelable?) -> Void)?,
                     updatedTotal: ((String?) -> Void)?,
                     completion: ((Result<Order?, Error>) -> Void)? ) {
        
        Task {
            do {
                isLoading?(true)
                let order = try await makePayment(target: target,
                                          sourceView: sourceView,
                                          request: request,
                                          status: status,
                                          cancel: cancel,
                                          updatedTotal: updatedTotal)
                isLoading?(false)
                completion?(.success(order))
            } catch {
                isLoading?(false)
                completion?(.failure(error))
            }
        }
    }
    
    private func makePayment(target: BaseViewController?,
                             sourceView: UIView,
                             request: OrderRequest?,
                             status: ((String) -> Void)?,
                             cancel: ((Cancelable?) -> Void)?,
                             updatedTotal: ((String?) -> Void)?) async throws -> Order? {
        
        guard let request = request else { return nil }
        
        status?("Pushing order...")
        let response: OrderResponse = try await APIManager.pushOrder(request: request).makeRequest()
        
        let uuid = response.order.uuid
        
        status?("Requesting payment intent...")
        let secretResponse: ClientSecretResponse = try await APIManager.requestPaymentIntent(orderUUID: uuid).makeRequest()
        let secret = secretResponse.clientSecret
        
        status?("Retrieving payment intent...")
        var intent = try await Terminal.shared.retrievePaymentIntent(clientSecret: secret)
        
        status?("Collecting payment method...")
        intent = try await collectPaymentMethod(intent: intent, cancel: cancel)
        
        if LocalStorage.readerType == .bluetooth {
            
            status?("Fetching tips recommendations...")
            let recomm: TipRecommendations = try await APIManager.fetchTipsRecommendation(orderUUID: uuid).makeRequest()
            
            status?("Collecting tips...")
            if let tip: TipsRequest = try await getTipRequest(target: target, sourseView: sourceView, recom: recomm) {
                
                status?("Updating order with tips...")
                let order: Order = try await APIManager.updateTips(orderUUID: uuid, request: tip).makeRequest()
                updatedTotal?(order.totalString)
            }
        }
        
        status?("Confirming payment intent...")
        let (processResult, processError) = await Terminal.shared.confirmPaymentIntent(intent)
        
        if let error = processError {
            throw error
        }
        
        if let amount = processResult?.amount {
            let double = Double(amount)/100
            let string = NumberFormatter.currency.string(for: double)
            updatedTotal?(string)
        }
        
        guard let stripeId = processResult?.stripeId else { return nil }
        
        status?("Capturing payment...")
        let void: VoidResult = try await APIManager.captureStripePayment(stripeId: stripeId).makeRequest()
        
        status?("Checking payment...")
        let order: Order = try await APIManager.checkStripePayment(orderUUID: uuid).makeRequest()
        
        return order
    }
    
    private func collectPaymentMethod(intent: PaymentIntent,
                                      cancel: ((Cancelable?) -> Void)?) async throws -> PaymentIntent {
        
//        let tippingConfig = try TippingConfigurationBuilder()
//            .setEligibleAmount(1500)
//            .build()
//        
      //  let collectConfig = try CollectConfigurationBuilder()
        //.setTippingConfiguration(tippingConfig)
//            .setEnableCustomerCancellation(true)
//            .build()
        
        return try await withCheckedThrowingContinuation { continuation in
            let cancellable = Terminal.shared.collectPaymentMethod(
                intent
                //collectConfig: collectConfig
            ) { collectResult, collectError in
                
                if let error = collectError {
                    print("collectPaymentMethod failed: \(error)")
                    continuation.resume(with: .failure(error))
                }
                else if let paymentIntent = collectResult {
                    print("collectPaymentMethod succeeded")
                    continuation.resume(with: .success(paymentIntent))
                    // ... Confirm the payment
                }
            }
            cancel?(cancellable)
        }
    }
    
    
    func getTipRequest(target: BaseViewController?,
                       sourseView: UIView,
                       recom: TipRecommendations) async throws -> TipsRequest? {
        
        let tips = recom.toRequests
        return try await self.presentTipsPicker(target: target, sourceView: sourseView, tips: tips)
    }
    
    @MainActor
    func presentTipsPicker(target: BaseViewController?, sourceView: UIView, tips: [TipsRequest]) async throws -> TipsRequest? {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            let alert = UIAlertController(title: "Select Tips", message: nil, preferredStyle: .actionSheet)
            
            tips.forEach({ tip in
                let action = UIAlertAction(title: tip.nameString, style: .default, handler: { _ in
                    continuation.resume(with: .success(tip))
                })
                alert.addAction(action)
            })
            
            let cancel = UIAlertAction(title: "Skip", style: .cancel) { _ in
                continuation.resume(with: .success(nil))
            }
            alert.addAction(cancel)
            
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.frame
            
            target?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func readGiftCard() async throws -> String {
        let config = try CollectDataConfigurationBuilder().setCollectDataType(.magstripe).build()
        
        return try await withCheckedThrowingContinuation { continuation in
            let cancelable = Terminal.shared.collectData(config) { collectedData, collectError in
                if let error = collectError {
                    // Handle read errors
                    print("Collect data failed: \(error)")
                    continuation.resume(with: .failure(error))
                } else if let data = collectedData, let stripeId = data.stripeId {
                    print("Received collected data token: \(stripeId)")
                    continuation.resume(with: .success(stripeId))
                }
            }
        }
    }
        
}
