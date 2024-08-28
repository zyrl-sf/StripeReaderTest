//
//  UIButton+.swift
//  ZYRLPad
//
//  Created by Максим on 26.10.2023.
//  Copyright © 2023 iOS Master. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setFont(font: UIFont?) {
        
        guard configuration != nil else {
            titleLabel?.font = font
            return
        }
        
        configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
    }
    
    func setImage(image: UIImage, padding: CGFloat = 16, placement: NSDirectionalRectEdge = .leading) {
        guard configuration != nil else {
            self.setImage(image, for: .normal)
            return
        }
        
        configuration?.image = image
        configuration?.imagePadding = padding
        configuration?.imagePlacement = placement
    }
    
    func setInsets(insets: UIEdgeInsets) {
        
        guard configuration != nil else {
            contentEdgeInsets = insets
            return
        }
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
        
    }
    
}
