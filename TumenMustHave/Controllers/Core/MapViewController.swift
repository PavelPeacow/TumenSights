//
//  ViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 29.09.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    private var sights = JsonDecoder.shared.getJsonData() ?? []
    private var sightRouteCoordinate: CLLocationCoordinate2D?
    
    private let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let startRouteBtn: UIButton = {
        let startRouteBtn = UIButton(configuration: UIButton.Configuration.filled())
        startRouteBtn.translatesAutoresizingMaskIntoConstraints = false
        startRouteBtn.setTitle("Начать маршрут", for: .normal)
        startRouteBtn.tintColor = .systemGreen
//        startRouteBtn.titleLabel?.adjustsFontSizeToFitWidth = true
//        startRouteBtn.isHidden = true
        return startRouteBtn
    }()
    
    private let cancelRouteBtn: UIButton = {
        let cancelRouteBtn = UIButton(configuration: UIButton.Configuration.filled())
        cancelRouteBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelRouteBtn.setTitle("Отменить маршрут", for: .normal)
        cancelRouteBtn.tintColor = .systemRed
//        cancelRouteBtn.titleLabel?.adjustsFontSizeToFitWidth = true
//        cancelRouteBtn.isHidden = true
        return cancelRouteBtn
    }()
    
    private lazy var stopMonitoringNavBarItem = UIBarButtonItem(image: UIImage(systemName: "location.fill"), style: .done, target: self, action: #selector(stopMonitoringUserLocation))
    
    private lazy var startMonitoringNavBarItem = UIBarButtonItem(image: UIImage(systemName: "location.slash.fill"), style: .done, target: self, action: #selector(startMonitoringUserLocation))
    
    private lazy var cancelCurrentRouteNavBarItem = UIBarButtonItem(image: UIImage(systemName: "x.circle.fill"), style: .done, target: self, action: #selector(cancelCurrentRoute))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            stopMonitoringUserLocation()
        }
        
        view.addSubview(mapView)
        
        view.addSubview(startRouteBtn)
        view.addSubview(cancelRouteBtn)
        
        centerMapCamera()
        addAnnotationsToMap()
        addCircleRadiusToAnnotations()
        
        setNavBar()
        setDelegates()
        setConstraints()
    }
    
    private func setDelegates() {
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    private func setNavBar() {
        if locationManager.authorizationStatus != .authorizedWhenInUse || locationManager.authorizationStatus != .authorizedAlways {
            navigationItem.rightBarButtonItem = startMonitoringNavBarItem
        } else {
            navigationItem.rightBarButtonItem = stopMonitoringNavBarItem
        }
    }
    
    private func centerMapCamera() {
        let coordinate = CLLocationCoordinate2D(latitude: 57.148470, longitude: 65.549138)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func startMonitoringUserLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            requestUserLocation()
            return
        }
        
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        navigationItem.rightBarButtonItem = stopMonitoringNavBarItem
    }
    
    @objc private func stopMonitoringUserLocation() {
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
        cancelCurrentRoute()
        navigationItem.rightBarButtonItem = startMonitoringNavBarItem
    }
    
    @objc private func cancelCurrentRoute() {
        sightRouteCoordinate = nil
        navigationItem.leftBarButtonItem = nil
        
        self.mapView.overlays.forEach {
            if $0.isKind(of: MKPolyline.self) {
                self.mapView.removeOverlay($0)
            }
        }
    }
    
    private func addAnnotationsToMap() {
        print(sights)
        
        for sight in sights {
            let someSight = SightOnMap(title: sight.name, coordinate: CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude), subtitle: sight.subtitle)
            mapView.addAnnotation(someSight)
        }
    }
    
    private func addCircleRadiusToAnnotations() {
        for sight in sights {
            let center = CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude)
            let circle = MKCircle(center: center, radius: 80)
            mapView.addOverlay(circle)
        }
    }
    
    private func requestUserLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showTurnUserLocationOnDeviceAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManagerDidChangeAuthorization(locationManager)
        print("peremoga")
    }
    
    private func createDirectionsRequest(from userCoordinate: CLLocationCoordinate2D, to coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let sourse = MKPlacemark(coordinate: userCoordinate)
        let destination = MKPlacemark(coordinate: coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourse)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        return request
    }
    
    private func calculateDistance(userCoordinate: CLLocationCoordinate2D, sightCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let sightLocation = CLLocation(latitude: sightCoordinate.latitude, longitude: sightCoordinate.longitude)
        
        let distanse = userLocation.distance(from: sightLocation)
        return distanse
    }
    
    private func pushSightDetailView(with sight: SightOnMap) {
        
        let sightDetail = SightDetail(name: sight.title!, subtitle: sight.subtitle!, coordinate: sight.coordinate)
        
        let vc = SightDetailViewController()
        vc.delegate = self
        vc.configure(with: sightDetail)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MapViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            cancelRouteBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            cancelRouteBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
            cancelRouteBtn.heightAnchor.constraint(equalToConstant: 40),
            cancelRouteBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            
            startRouteBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            startRouteBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
            startRouteBtn.heightAnchor.constraint(equalToConstant: 40),
            startRouteBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
        ])
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
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
        
        pushSightDetailView(with: sight)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isKind(of: MKPolyline.self) {
            let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
            renderer.strokeColor = .green
            return renderer
        }
        
        if overlay.isKind(of: MKCircle.self) {
            let circleRender = MKCircleRenderer(overlay: overlay as! MKCircle)
            circleRender.fillColor = .blue
            circleRender.alpha = 0.5
            return circleRender
        }
        
        return MKOverlayRenderer(overlay: overlay)
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            showTurnUserLocationOnDeviceAlert()
            navigationItem.rightBarButtonItem = startMonitoringNavBarItem
            print("denied")
        case .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            navigationItem.rightBarButtonItem = stopMonitoringNavBarItem
            print("authorizedAlways")
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            navigationItem.rightBarButtonItem = stopMonitoringNavBarItem
            print("authorizedWhenInUse")
        @unknown default:
            print("new status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userCoordinate = locations.first?.coordinate else { return }
        guard let sightCoordinate = sightRouteCoordinate else { return }
        print(userCoordinate)
        
        let request = createDirectionsRequest(from: userCoordinate, to: sightCoordinate)
        let directions = MKDirections(request: request)
        
        let distance = calculateDistance(userCoordinate: userCoordinate, sightCoordinate: sightCoordinate)
        
        print(distance)
        
        if distance <= 80 {
            print("you get to sight safe and sound")
            cancelCurrentRoute()
            return
        }
        
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let response = response else {
                print("unable to calculate")
                return
            }
            
            self.mapView.overlays.forEach {
                if $0.isKind(of: MKPolyline.self) {
                    self.mapView.removeOverlay($0)
                }
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
            self.navigationItem.leftBarButtonItem = self.cancelCurrentRouteNavBarItem
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

extension MapViewController: GetRouteDelegate {
    
    func getSightCoordinates(_ coordinate: CLLocationCoordinate2D) {
        sightRouteCoordinate = coordinate
    }
}
