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
    
    private var didStartRoute = false
    private var isCenteringModeOn = false
    
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
    
    private lazy var startRouteBtn: UIButton = {
        let startRouteBtn = UIButton(configuration: UIButton.Configuration.filled())
        startRouteBtn.translatesAutoresizingMaskIntoConstraints = false
        startRouteBtn.setTitle("Начать маршрут", for: .normal)
        startRouteBtn.tintColor = .systemGreen
        startRouteBtn.addTarget(self, action: #selector(didTappStartRouteBtn), for: .touchUpInside)
        startRouteBtn.isHidden = true
        return startRouteBtn
    }()
    
    private lazy var cancelRouteBtn: UIButton = {
        let cancelRouteBtn = UIButton(configuration: UIButton.Configuration.filled())
        cancelRouteBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelRouteBtn.setTitle("Отменить маршрут", for: .normal)
        cancelRouteBtn.tintColor = .systemRed
        cancelRouteBtn.addTarget(self, action: #selector(didTappCancelRouteBtn), for: .touchUpInside)
        cancelRouteBtn.isHidden = true
        return cancelRouteBtn
    }()
    
    private lazy var toggleRouteMonitoringModeBtn: UIButton = {
        let toggleRouteMonitoringModeBtn = UIButton()
        toggleRouteMonitoringModeBtn.translatesAutoresizingMaskIntoConstraints = false
        toggleRouteMonitoringModeBtn.addTarget(self, action: #selector(toggleRouteMonitoringMode(_:)), for: .touchUpInside)
        toggleRouteMonitoringModeBtn.setImage(UIImage(systemName: "location.fill"), for: .normal)
        toggleRouteMonitoringModeBtn.layer.borderWidth = 2
        toggleRouteMonitoringModeBtn.backgroundColor = .systemBackground
        toggleRouteMonitoringModeBtn.clipsToBounds = true
        toggleRouteMonitoringModeBtn.layer.cornerRadius = 20
        toggleRouteMonitoringModeBtn.isHidden = true
        return toggleRouteMonitoringModeBtn
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
        view.addSubview(toggleRouteMonitoringModeBtn)
        
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
    
    @objc private func toggleRouteMonitoringMode(_ sender: UIButton) {
        guard let userCoordinate = locationManager.location?.coordinate else { return }
        isCenteringModeOn.toggle()
        
        if isCenteringModeOn {
            centerMapOnUserLocation(with: userCoordinate)
            sender.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "location.fill"), for: .normal)
        }
    }
    
    @objc private func cancelCurrentRoute() {
        didStartRoute = false
        toggleRouteMonitoringModeBtn.isHidden = true
        sightRouteCoordinate = nil
        navigationItem.leftBarButtonItem = nil
        
        self.mapView.overlays.forEach {
            if $0.isKind(of: MKPolyline.self) {
                self.mapView.removeOverlay($0)
            }
        }
    }
    
    @objc private func didTappStartRouteBtn() {
        didStartRoute = true
        toggleRouteMonitoringModeBtn.isHidden = false
        startRouteBtn.isHidden = true
        cancelRouteBtn.isHidden = true
        navigationItem.leftBarButtonItem = cancelCurrentRouteNavBarItem
    }
    
    @objc private func didTappCancelRouteBtn() {
        cancelCurrentRoute()
        startRouteBtn.isHidden = true
        cancelRouteBtn.isHidden = true
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
    
    private func calculateDirectionRoute(with request: MKDirections.Request) {
        let request = request
        let directions = MKDirections(request: request)
        
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
                
                if !self.didStartRoute  {
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
                
            }
            
        }
    }
    
    private func centerMapOnUserLocation(with userCoordinate: CLLocationCoordinate2D) {
        guard isCenteringModeOn else { return }
        let center = CLLocationCoordinate2D(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
    }
    
}

extension MapViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            toggleRouteMonitoringModeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            toggleRouteMonitoringModeBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 25),
            toggleRouteMonitoringModeBtn.heightAnchor.constraint(equalToConstant: 40),
            toggleRouteMonitoringModeBtn.widthAnchor.constraint(equalToConstant: 40),
            
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
        mapView.deselectAnnotation(view.annotation, animated: true)
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
        let distance = calculateDistance(userCoordinate: userCoordinate, sightCoordinate: sightCoordinate)
        
        print(distance)
        
        if distance <= 80 {
            print("you get to sight safe and sound")
            cancelCurrentRoute()
            return
        }
        
        centerMapOnUserLocation(with: userCoordinate)
        calculateDirectionRoute(with: request)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

extension MapViewController: GetRouteDelegate {
    
    func getSightCoordinates(_ coordinate: CLLocationCoordinate2D) {
        guard mapView.showsUserLocation else { return }
        guard let userCoordinate = locationManager.location?.coordinate else { return }
        cancelCurrentRoute()
        sightRouteCoordinate = coordinate
        
        let request = createDirectionsRequest(from: userCoordinate, to: sightRouteCoordinate!)
        calculateDirectionRoute(with: request)
        
        startRouteBtn.isHidden = false
        cancelRouteBtn.isHidden = false
    }
}
