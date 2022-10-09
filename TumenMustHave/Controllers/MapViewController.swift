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
        startMonitoringUserLocation()
        
        view.addSubview(mapView)
        
        centerMapCamera()
        addAnnotationsToMap()
        addCircleRadiusToAnnotations()
        
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
    
    private func startMonitoringUserLocation() {
        if userLocationManager.authorizationStatus == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            userLocationManager.startUpdatingLocation()
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
    
    @objc private func requestUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            userLocationManager.requestWhenInUseAuthorization()
            locationManagerDidChangeAuthorization(userLocationManager)
            print("peremoga")
        } else {
            showTurnUserLocationOnDeviceAlert()
        }
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
    
}

extension MapViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        
        let sightDetail = SightDetail(name: sight.title!, subtitle: sight.subtitle!, coordinate: sight.coordinate)
        
        let vc = SightDetailViewController()
        vc.delegate = self
        vc.configure(with: sightDetail)
        
        navigationController?.pushViewController(vc, animated: true)
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
        guard let userLocation = locations.first?.coordinate else { return }
        guard let sightCoordinate = sightRouteCoordinate else { return }
        print(userLocation)
        
        let request = createDirectionsRequest(from: userLocation, to: sightCoordinate)
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
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
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
