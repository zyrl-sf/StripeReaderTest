//
//  StripeUpdateView.swift
//  ZYRLPad
//
//  Created by Maxim on 10/21/21.
//  Copyright © 2021 iOS Master. All rights reserved.
//

import UIKit

class StripeUpdateView: UIView {
    
    private let blurredEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    private let shadowView: TappableClippedView = {
        let view = TappableClippedView()
        view.layer.cornerRadius = 24
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.setMediumShadow()
        return view
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()
    
    private let mainContainer: UIStackView = {
        $0.axis = .vertical
        return $0
    }(UIStackView())
    
    lazy var titleLabel: UILabel = {
        $0.text = "Stripe Updating..."
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var subtitleLabel: UILabel = {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var statusLabel: UILabel = {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 2
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    lazy var progressBar: UIProgressView = {
        $0.tintColor = .systemBlue
        $0.snp.makeConstraints({ $0.height.equalTo(4) })
        return $0
    }(UIProgressView())
    
    private weak var viewController: UIViewController?
    
    init(updateName: String?, viewController: UIViewController?) {
        super.init(frame: .zero)
        
        self.subtitleLabel.text = updateName
        self.viewController = viewController
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        
        backgroundColor = .clear

        addSubview(blurredEffectView)
        blurredEffectView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        addSubview(shadowView)
        shadowView.snp.makeConstraints({
            $0.width.equalTo(400)
            $0.center.equalToSuperview()
        })
        
        shadowView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        backgroundView.addSubview(mainContainer)
        mainContainer.snp.makeConstraints({ $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 40, left: 30, bottom: 40, right: 30)) })
        
        mainContainer.addArrangedSubviews([titleLabel, subtitleLabel, statusLabel, progressBar])
        
        mainContainer.setCustomSpacing(20, after: titleLabel)
        mainContainer.setCustomSpacing(20, after: subtitleLabel)
        mainContainer.setCustomSpacing(20, after: statusLabel)

    }
    
    func update(progress: Float) {
        progressBar.progress = progress
    }
    
    func update(estimateTime: String) {
        statusLabel.text = estimateTime
    }
    
    func present(view: UIView? = nil) {
        
        (view ?? viewController?.view)?.addSubview(self)
        self.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}
