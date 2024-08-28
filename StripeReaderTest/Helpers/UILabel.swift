//
//  UILabel.swift
//  ZYRLPad
//
//  Created by Maxim on 21.09.2022.
//  Copyright © 2022 iOS Master. All rights reserved.
//
import UIKit
import Foundation

extension UILabel {
    
    func setTitlePriority(label: UILabel, axis: NSLayoutConstraint.Axis = .vertical) {
        setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: axis)
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: axis)
        
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: axis)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: axis)
    }
    
}

class PaddingLabel: UILabel {
    
    var topInset: CGFloat
    var bottomInset: CGFloat
    var leftInset: CGFloat
    var rightInset: CGFloat
    
    required init(withInsets top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
    
}
