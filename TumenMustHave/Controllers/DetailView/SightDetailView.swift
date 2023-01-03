//
//  SightDetailView.swift
//  TumenMustHave
//
//  Created by Павел Кай on 02.01.2023.
//

import UIKit

final class SightDetailView: UIView {
    
    lazy var scrollView: UIScrollView = UIScrollView()
    
    lazy var sightImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var sightName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var sightDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stackViewBtns: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [getRouteBtn, markAsVisitedSightBtn, unmarkAsVisitedSightBtn])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var getRouteBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .darkGray
        btn.setTitle("Построить маршрут", for: .normal)
        return btn
    }()
    
    lazy var markAsVisitedSightBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .systemGreen
        btn.setTitle("Отметить как посещенное", for: .normal)
        return btn
    }()
    
    lazy var unmarkAsVisitedSightBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .systemRed
        btn.setTitle("Убрать из посещенных", for: .normal)
        return btn
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .systemBackground
        
        addSubview(scrollView)
        scrollView.addSubview(sightImage)
        scrollView.addSubview(sightName)
        scrollView.addSubview(sightDescription)
        scrollView.addSubview(stackViewBtns)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension SightDetailView {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            sightImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            sightImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            sightImage.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            sightImage.heightAnchor.constraint(equalToConstant: 300),
            
            sightName.topAnchor.constraint(equalTo: sightImage.bottomAnchor, constant: 10),
            sightName.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            sightDescription.topAnchor.constraint(equalTo: sightName.bottomAnchor, constant: 15),
            sightDescription.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            sightDescription.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            stackViewBtns.topAnchor.constraint(equalTo: sightDescription.bottomAnchor, constant: 20),
            stackViewBtns.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackViewBtns.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            stackViewBtns.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -15),
        ])
    }
}
