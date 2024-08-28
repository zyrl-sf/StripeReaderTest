//
//  BaseViewController.swift
//  StripeReaderTest
//
//  Created by Максим on 15.08.2024.
//

import UIKit


class BaseViewController: UIViewController {
    
    var nextHandler: (() -> Void)?
    
    private var loader: UIActivityIndicatorView = {
        return $0
    }(UIActivityIndicatorView(style: .large))
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(loader)
        loader.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLoading(state: Bool) {
        if state {
            showLoading()
        } else {
            hideLoading()
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.loader)
            self.loader.startAnimating()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.loader.stopAnimating()
        }
    }
    
    @objc func nextTapped() {
        nextHandler?()
    }
    
}
