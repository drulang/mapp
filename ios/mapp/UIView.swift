//
//  UIView.swift
//  mapp
//
//  Created by Dru Lang on 2/5/17.
//  Copyright © 2017 Dru Lang. All rights reserved.
//

import UIKit

extension UIView {
    func box() {
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 1
    }
    
    func boxTheHellOutOfEverything() {
        box()
        for view in subviews {
            view.boxTheHellOutOfEverything()
        }
    }
    
    func borderfy() {
        self.layer.borderColor = Appearance.Layer.BorderColor.cgColor
        self.layer.borderWidth = Appearance.Layer.BorderWidth
    }
    
    func cornerfy() {
        self.layer.cornerRadius = Appearance.Layer.CornerRadius
    }
}
