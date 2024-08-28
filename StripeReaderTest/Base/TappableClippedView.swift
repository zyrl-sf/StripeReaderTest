//
//  TappableClippedView.swift
//  ZYRLPad
//
//  Created by Maxim on 12/2/21.
//  Copyright © 2021 iOS Master. All rights reserved.
//

import UIKit

class TappableClippedView: UIView {
    override func hitTest(_ point: CGPoint, with e: UIEvent?) -> UIView? {
        if let result = super.hitTest(point, with:e) {
            return result
        }
        for sub in self.subviews.reversed() {
            let pt = self.convert(point, to:sub)
            if let result = sub.hitTest(pt, with:e) {
                return result
            }
        }
        return nil
    }
}
