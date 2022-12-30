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
    
    let mapView = MapView()
    var viewModel: MapViewViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    private lazy var cancelCurrentRouteNavBarItem = UIBarButtonItem(image: UIImage(systemName: "x.circle.fill"), style: .done, target: self, action: #selector(cancelCurrentRoute))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MapViewViewModel()
        view.backgroundColor = .systemBackground
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.map.setRegion(viewModel.centerMapCamera(), animated: true)

        viewModel.addAnnotationsToMap()
        viewModel.addCircleRadiusToAnnotations()
        
        setNavBar()
        setTargets()
        setDelegates()
    }
    
    override func loadView() {
        super.loadView()
        view = mapView
    }
    
    private func setDelegates() {
        mapView.map.delegate = self
        locationManager.delegate = self
    }
    
    private func setTargets() {
        mapView.turnOnLocationServicesBtn.addTarget(self, action: #selector(requestUserLocation), for: .touchUpInside)
        mapView.startRouteBtn.addTarget(self, action: #selector(didTappStartRouteBtn), for: .touchUpInside)
        mapView.cancelRouteBtn.addTarget(self, action: #selector(didTappCancelRouteBtn), for: .touchUpInside)
        mapView.toggleRouteMonitoringModeBtn.addTarget(self, action: #selector(toggleRouteMonitoringMode(_:)), for: .touchUpInside)
    }
    
    private func setNavBar() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            navigationItem.titleView = mapView.turnOnLocationServicesBtn
            return
        }
        
        navigationItem.titleView = nil
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
    
    @objc private func toggleRouteMonitoringMode(_ sender: UIButton) {
        guard let userCoordinate = locationManager.location?.coordinate else { return }
        viewModel.isCenteringModeOn.toggle()
        
        if viewModel.isCenteringModeOn {
            if let region = viewModel.centerMapOnUserLocation(with: userCoordinate) {
                mapView.map.setRegion(region, animated: true)
            }
            
            sender.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "location.fill"), for: .normal)
        }
    }
    
    @objc private func cancelCurrentRoute() {
        viewModel.didStartRoute = false
        mapView.toggleRouteMonitoringModeBtn.isHidden = true
        viewModel.sightRouteCoordinate = nil
        navigationItem.leftBarButtonItem = nil
        
        self.mapView.map.overlays.forEach {
            if $0.isKind(of: MKPolyline.self) {
                self.mapView.map.removeOverlay($0)
            }
        }
    }
    
    @objc private func didTappStartRouteBtn() {
        viewModel.didStartRoute = true
        mapView.toggleRouteMonitoringModeBtn.isHidden = false
        mapView.startRouteBtn.isHidden = true
        mapView.cancelRouteBtn.isHidden = true
        navigationItem.leftBarButtonItem = cancelCurrentRouteNavBarItem
    }
    
    @objc private func didTappCancelRouteBtn() {
        cancelCurrentRoute()
        mapView.startRouteBtn.isHidden = true
        mapView.cancelRouteBtn.isHidden = true
    }
    
    @objc private func requestUserLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showTurnUserLocationOnDeviceAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManagerDidChangeAuthorization(locationManager)
    }
}

extension MapViewController: MapViewViewModelDelegate {
    
    func viewModelDidAddAnnotation(_ viewModel: MapViewViewModel) {
        mapView.map.addAnnotations(viewModel.annotations)
    }
    
    func viewModelDidAddOverlay(_ viewModel: MapViewViewModel) {
        mapView.map.addOverlays(viewModel.overlays)
    }
    
    func viewModelDidUpdateDirection(_ viewModel: MapViewViewModel) {
        
        mapView.map.overlays.forEach {
            if $0.isKind(of: MKPolyline.self) {
                mapView.map.removeOverlay($0)
            }
        }
        
        for route in viewModel.directions {
            mapView.map.addOverlay(route.polyline)
            
            if !viewModel.didStartRoute  {
                mapView.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is SightOnMap else { return MKAnnotationView() }
        
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
            
            locationManager.requestWhenInUseAuthorization()
            navigationItem.titleView = mapView.turnOnLocationServicesBtn
            print("notDetermined")
            
        case .restricted:
            
            print("restricted")
            
        case .denied:
            
            showTurnUserLocationOnDeviceAlert()
            navigationItem.titleView = mapView.turnOnLocationServicesBtn
            print("denied")
            
        case .authorizedAlways, .authorizedWhenInUse:
            
            navigationItem.titleView = nil
            locationManager.startUpdatingLocation()
            print("authorizedAlways or authorizedWhenInUse")
            
        @unknown default:
            print("new status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userCoordinate = locations.first?.coordinate else { return }
        guard let sightCoordinate = viewModel.sightRouteCoordinate else { return }
        
        print(userCoordinate)
        
        let request = viewModel.createDirectionsRequest(from: userCoordinate, to: sightCoordinate)
        let distance = viewModel.calculateDistance(userCoordinate: userCoordinate, sightCoordinate: sightCoordinate)
        
        print(distance)
        
        if distance <= 80 {
            print("you get to sight safe and sound")
            cancelCurrentRoute()
            return
        }
        
        if let region = viewModel.centerMapOnUserLocation(with: userCoordinate) {
            mapView.map.setRegion(region, animated: true)
        }
        
        
        viewModel.calculateDirectionRoute(with: request)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

extension MapViewController: GetRouteDelegate {
    
    func getSightCoordinates(_ coordinate: CLLocationCoordinate2D) {
        guard mapView.map.showsUserLocation else { return }
        guard let userCoordinate = locationManager.location?.coordinate else { return }
        cancelCurrentRoute()
        viewModel.sightRouteCoordinate = coordinate
        
        let request = viewModel.createDirectionsRequest(from: userCoordinate, to: viewModel.sightRouteCoordinate!)
        viewModel.calculateDirectionRoute(with: request)
        
        mapView.startRouteBtn.isHidden = false
        mapView.cancelRouteBtn.isHidden = false
    }
}
