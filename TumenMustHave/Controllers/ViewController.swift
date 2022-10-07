//
//  ViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 29.09.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    private var sights = JsonDecoder.shared.getJsonData() ?? []
    
    private let userLocationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
        
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private lazy var navBarItem = UIBarButtonItem(image: UIImage(systemName: "location.fill"), style: .done, target: self, action: #selector(requestUserLocation))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        
        centerMapCamera()
        addAnnotationsToMap()
        
        setNavBar()
        setDelegates()
        setConstraints()
    }
    
    private func setDelegates() {
        mapView.delegate = self
        userLocationManager.delegate = self
    }
    
    private func setNavBar() {
        navigationItem.rightBarButtonItem = navBarItem
    }
    
    private func centerMapCamera() {
        let coordinate = CLLocationCoordinate2D(latitude: 57.148470, longitude: 65.549138)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func addAnnotationsToMap() {
        
        print(sights)

        for sight in sights {
            let someSight = SightOnMap(title: sight.name, coordinate: CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude), subtitle: sight.subtitle)
            mapView.addAnnotation(someSight)
        }
    }
    
    @objc private func requestUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            userLocationManager.requestWhenInUseAuthorization()
            locationManagerDidChangeAuthorization(userLocationManager)
            print("peremoga")
        } else {
            showTurnUserLocationOnDeviceAlert()
        }
    }
    
}

extension ViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is SightOnMap else { return nil }
        
        let identifier = "Sight"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = .green
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.font = detailLabel.font.withSize(12)
        detailLabel.text = annotation.subtitle!
        annotationView?.detailCalloutAccessoryView = detailLabel
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.setSelected(false, animated: true)
        let sight = view.annotation as! SightOnMap
        let sightDetail = SightDetail(name: sight.title!, subtitle: sight.subtitle!)
        let vc = SightDetailViewController()
        vc.configure(with: sightDetail)

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            userLocationManager.requestWhenInUseAuthorization()
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            showTurnUserLocationOnDeviceAlert()
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            userLocationManager.startUpdatingLocation()
            print("authorizedWhenInUse")
        @unknown default:
            print("new status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
