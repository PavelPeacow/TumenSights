//
//  MapView.swift
//  TumenMustHave
//
//  Created by Павел Кай on 30.12.2022.
//

import UIKit
import MapKit

final class MapView: UIView {
    
    lazy var map: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    lazy var turnOnLocationServicesBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        btn.setTitle("Включите отслеживание", for: .normal)
        btn.setBlur()
        return btn
    }()
    
    lazy var cancelRouteNavBarBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        btn.setBlur()
        return btn
    }()
    
    lazy var startRouteBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Начать маршрут", for: .normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.setTitleColor(.green, for: .normal)
        btn.isHidden = true
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        btn.setBlur()
        return btn
    }()
    
    lazy var cancelRouteBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Отменить маршрут", for: .normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.setTitleColor(.red, for: .normal)
        btn.isHidden = true
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        btn.setBlur()
        return btn
    }()
    
    lazy var toggleRouteMonitoringModeBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "location.fill"), for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 25
        btn.isHidden = true
        btn.setBlur()
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(map)
        addSubview(startRouteBtn)
        addSubview(cancelRouteBtn)
        addSubview(toggleRouteMonitoringModeBtn)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapView {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: topAnchor),
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            toggleRouteMonitoringModeBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60),
            toggleRouteMonitoringModeBtn.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
            toggleRouteMonitoringModeBtn.heightAnchor.constraint(equalToConstant: 50),
            toggleRouteMonitoringModeBtn.widthAnchor.constraint(equalToConstant: 50),
            
            cancelRouteBtn.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            cancelRouteBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -35),
            cancelRouteBtn.heightAnchor.constraint(equalToConstant: 40),
            cancelRouteBtn.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            
            startRouteBtn.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            startRouteBtn.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -35),
            startRouteBtn.heightAnchor.constraint(equalToConstant: 40),
            startRouteBtn.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
        ])
    }
    
}
