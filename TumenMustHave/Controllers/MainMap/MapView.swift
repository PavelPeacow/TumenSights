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
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 5
        
        let turnOnLocationServicesBtn = UIButton(configuration: configuration)
        turnOnLocationServicesBtn.setTitle("Turn on location services", for: .normal)
        turnOnLocationServicesBtn.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        return turnOnLocationServicesBtn
    }()
    
    lazy var startRouteBtn: UIButton = {
        let startRouteBtn = UIButton(configuration: UIButton.Configuration.filled())
        startRouteBtn.translatesAutoresizingMaskIntoConstraints = false
        startRouteBtn.setTitle("Начать маршрут", for: .normal)
        startRouteBtn.tintColor = .systemGreen
        startRouteBtn.isHidden = true
        return startRouteBtn
    }()
    
    lazy var cancelRouteBtn: UIButton = {
        let cancelRouteBtn = UIButton(configuration: UIButton.Configuration.filled())
        cancelRouteBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelRouteBtn.setTitle("Отменить маршрут", for: .normal)
        cancelRouteBtn.tintColor = .systemRed
        cancelRouteBtn.isHidden = true
        return cancelRouteBtn
    }()
    
    lazy var toggleRouteMonitoringModeBtn: UIButton = {
        let toggleRouteMonitoringModeBtn = UIButton()
        toggleRouteMonitoringModeBtn.translatesAutoresizingMaskIntoConstraints = false
        toggleRouteMonitoringModeBtn.setImage(UIImage(systemName: "location.fill"), for: .normal)
        toggleRouteMonitoringModeBtn.layer.borderWidth = 2
        toggleRouteMonitoringModeBtn.backgroundColor = .systemBackground
        toggleRouteMonitoringModeBtn.clipsToBounds = true
        toggleRouteMonitoringModeBtn.layer.cornerRadius = 20
        toggleRouteMonitoringModeBtn.isHidden = true
        return toggleRouteMonitoringModeBtn
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
            map.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            toggleRouteMonitoringModeBtn.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 25),
            toggleRouteMonitoringModeBtn.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -25),
            toggleRouteMonitoringModeBtn.heightAnchor.constraint(equalToConstant: 40),
            toggleRouteMonitoringModeBtn.widthAnchor.constraint(equalToConstant: 40),
            
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
