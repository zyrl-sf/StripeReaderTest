//
//  RoundedButton.swift
//  ZYRLUserApp
//
//  Created by  Macbook on 19.11.2020.
//  Copyright © 2020 Christopher Sukhram. All rights reserved.
//

import UIKit

struct RoundedButtonAppearance {
    static let titleFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    static let cornerRadius: CGFloat = 24
    static let backgroundColor = UIColor.systemBlue
}

final class CustomButton: UIButton, ButtonLoadable {
    
    var numberOfAnimations = 0
    var isLoaderAnimating = false
    
    var loader: UIActivityIndicatorView = {
        return $0
    }(UIActivityIndicatorView(style: .medium))
    
    var setEnabled: Bool {
        set {
            DispatchQueue.main.async {
                self.isEnabled = newValue
            }
        }
        
        get {
            return isEnabled
        }
    }
    
    typealias Appearance = RoundedButtonAppearance
    
    static func roundedButton(title: String? = nil,
                              backgroundColor: UIColor = .black,
                              foregroundColor: UIColor = .white,
                              font: UIFont? = Appearance.titleFont,
                              height: CGFloat = 65,
                              inset: CGFloat = 40,
                              insetTopBot: CGFloat = 0,
                              withShadow: Bool = true) -> CustomButton {
        return newButton(title: title, backgroundColor: backgroundColor, foregroundColor: foregroundColor, strokeColor: .clear, font: font, height: height, inset: inset, insetTopBot: insetTopBot, withShadow: withShadow)
    }
    
    static func roundedButtonBordered(title: String?,
                                      backgroundColor: UIColor = .clear,
                                      foregroundColor: UIColor = .black,
                                      font: UIFont? = Appearance.titleFont,
                                      height: CGFloat = 65,
                                      inset: CGFloat = 40,
                                      insetTopBot: CGFloat = 0,
                                      withShadow: Bool = false) -> CustomButton {
        return newButton(title: title, backgroundColor: backgroundColor, foregroundColor: foregroundColor, strokeColor: foregroundColor, strokeWidth: 1, font: font, height: height, inset: inset, insetTopBot: insetTopBot, withShadow: withShadow)
    }
    
    private static func newButton(buttonType: UIButton.ButtonType = .system,
                                  title: String?,
                                  backgroundColor: UIColor?,
                                  foregroundColor: UIColor?,
                                  strokeColor: UIColor?,
                                  strokeWidth: CGFloat = 0,
                                  font: UIFont?,
                                  height: CGFloat,
                                  inset: CGFloat,
                                  insetTopBot: CGFloat,
                                  withShadow: Bool) -> CustomButton {
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .fixed
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = foregroundColor
        config.background.strokeColor = strokeColor
        config.background.strokeWidth = strokeWidth
        config.contentInsets = NSDirectionalEdgeInsets(top: insetTopBot, leading: inset, bottom: insetTopBot, trailing: inset)
        config.title = title
        
        let b = CustomButton(type: buttonType)
        b.snp.makeConstraints({ $0.height.equalTo(height) })
        b.configuration = config
        b.setFont(font: font)
        return b
    }
    

    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                super.isHighlighted = false
            }
        }
    }
    
}


protocol ButtonLoadable: AnyObject {
    
    var numberOfAnimations: Int { get set }
    var isLoaderAnimating: Bool { get set }
    
    var loader: UIActivityIndicatorView { get }
    
    func showLoading(load: Bool)
}

extension ButtonLoadable where Self: UIControl {
    
    func showLoading(load: Bool) {
        
        if load {
            numberOfAnimations += 1
        } else {
            numberOfAnimations -= 1
        }
        
        numberOfAnimations = renderAnimation(counter: numberOfAnimations)
    }
    
    private func renderAnimation(counter: Int) -> Int {
        
        var newCounter = counter
        
        if counter > 0 {
            if !isLoaderAnimating {
                startLoaderLoading()
            }
        } else {
            stopLoaderLoading()
            newCounter = 0
        }
        
        return newCounter
    }
    
    private func startLoaderLoading() {
        DispatchQueue.main.async {
            self.isEnabled = false
            self.addSubview(self.loader)
            self.loader.snp.makeConstraints({ $0.center.equalToSuperview() })
            self.loader.isHidden = false
            self.loader.startAnimating()
            self.isLoaderAnimating = true
        }
    }
    
    private func stopLoaderLoading() {
        DispatchQueue.main.async {
            self.loader.removeFromSuperview()
            self.loader.stopAnimating()
            self.isEnabled = true
            self.isLoaderAnimating = false
        }
    }
    
}
