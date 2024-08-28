//
//  UIView+.swift
//  StripeReaderTest
//
//  Created by Максим on 20.08.2024.
//

import UIKit


extension UIView {
    
    func setMediumShadow() {
        setShadow(opacity: 0.3, radius: 3.5, offset: CGSize(width: 0, height: 3), color: .black)
    }
    
    func setShadow(opacity: CGFloat, radius: CGFloat, offset: CGSize, color: UIColor!) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = Float(opacity)
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
}
