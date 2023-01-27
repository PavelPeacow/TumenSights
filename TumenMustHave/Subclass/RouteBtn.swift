//
//  RouteBtn.swift
//  TumenMustHave
//
//  Created by Павел Кай on 27.01.2023.
//

import UIKit

final class RouteBtn: UIButton {
    
    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        titleLabel?.adjustsFontSizeToFitWidth = true
        setTitleColor(color, for: .normal)
        isHidden = true
        layer.cornerRadius = 15
        clipsToBounds = true
        setBlur()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
