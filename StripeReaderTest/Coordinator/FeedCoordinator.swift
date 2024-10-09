//
//  FeedCoordinator.swift
//  StripeReaderTest
//
//  Created by Максим on 19.08.2024.
//

import UIKit


class FeedCoordinator {
    
    static var currentConsole: ConsoleViewController?
    
    private lazy var readerBluetoothController: StripeBluetoothController = {
        $0.messageForUser = { [weak self] text in
            self?.payment?.showUserMessage(text: text)
        }
        return $0
    } (StripeBluetoothController())
    
    private lazy var stripeManager = StripeManager(connectionDelegate: nil,
                                                   bluetoothDelegate: readerBluetoothController, 
                                                   usbReaderDelegate: readerBluetoothController)
    
    lazy var tabbarController: UITabBarController = {
        $0.viewControllers = [loginNavigation, historyNavigation, scanner, console]
        return $0
    }(UITabBarController())
    
    private lazy var loginNavigation: UINavigationController = {
        return $0
    } (UINavigationController(rootViewController: loginVC))
    
    lazy var loginVC: LoginViewController = {
        $0.tabBarItem = UITabBarItem(title: "Order", image: UIImage(systemName: "cart"), tag: 0)
        $0.nextHandler = { [weak self] in
            self?.pushReader()
        }
        return $0
    }(LoginViewController(stripeManager: stripeManager))
    
    private lazy var historyNavigation = UINavigationController(rootViewController: historyVC)
    
    lazy var historyVC: OrderHistoryController = {
        $0.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "list.bullet.below.rectangle"), tag: 1)
        return $0
    }(OrderHistoryController())
    
    lazy var scanner: GiftCardScanner = {
        $0.tabBarItem = UITabBarItem(title: "Scanner", image: UIImage(systemName: "barcode.viewfinder"), tag: 2)
        return $0
    }(GiftCardScanner())
    
    lazy var console: ConsoleViewController = {
        $0.tabBarItem = UITabBarItem(title: "Console", image: UIImage(systemName: "apple.terminal"), tag: 3)
        FeedCoordinator.currentConsole = $0
        return $0
    }(ConsoleViewController())
    
    var menu: MenuViewController?
    var payment: PaymentViewController?
    
    init() { }
    
    func pushTabbar() -> UITabBarController {
        tabbarController
    }
    
    func pushReader() {
        let vc = ReaderViewController(stripeManager: stripeManager)
        vc.nextHandler = { [weak self] in
            self?.pushMenu()
        }
     //   vc.hidesBottomBarWhenPushed = true
        loginNavigation.pushViewController(vc, animated: true)
    }
    
    func pushMenu() {
        let vc = MenuViewController()
        vc.paymentRequestHandler = { [weak self, weak vc] orderRequest, orderResponse in
            self?.pushPayment(target: vc, orderRequest: orderRequest, orderResponse: orderResponse)
        }
        loginNavigation.pushViewController(vc, animated: true)
        self.menu = vc
    }
    
    func pushPayment(target: UIViewController?, orderRequest: OrderRequest?, orderResponse: OrderResponse?) {
        let vc = PaymentViewController(orderRequest: orderRequest, orderResponse: orderResponse)
        vc.nextHandler = { [weak self] in
            self?.menu?.reset()
        }
        vc.showAlert = { [weak self] text in
            self?.menu?.showAlert(message: text)
        }
        target?.present(vc, animated: true)
        payment = vc
    }

}
