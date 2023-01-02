//
//  UIButton+BlurEffect.swift
//  TumenMustHave
//
//  Created by Павел Кай on 02.01.2023.
//

import UIKit

extension UIButton {
    
    func setBlur() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isUserInteractionEnabled = false
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurView, at: 0)
        
        if let imageView = self.imageView {
            imageView.backgroundColor = .clear
            self.bringSubviewToFront(imageView)
        }
    }
    
}
