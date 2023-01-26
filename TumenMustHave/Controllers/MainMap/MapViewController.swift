//
//  ViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 29.09.2022.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {
    
    //MARK: Properties
    private let mapView = MapView()
    private var viewModel: MapViewViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    private lazy var cancelCurrentRouteNavBarItem = UIBarButtonItem(customView: mapView.cancelRouteNavBarBtn)
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        locationManager.requestWhenInUseAuthorization()
        
        setViewModel()
        setNavBar()
        setTargets()
        setDelegates()
    }
    
    override func loadView() {
        super.loadView()
        view = mapView
    }
    
    //MARK: Methods
    private func setDelegates() {
        mapView.map.delegate = self
        locationManager.delegate = self
    }
    
    private func setViewModel() {
        viewModel = MapViewViewModel()
        mapView.map.setRegion(viewModel.centerMapCamera(), animated: true)
        viewModel.addAnnotationsToMap()
        viewModel.addCircleRadiusToAnnotations()
    }
    
    private func setTargets() {
        mapView.turnOnLocationServicesBtn.addTarget(self, action: #selector(requestUserLocation), for: .touchUpInside)
        mapView.startRouteBtn.addTarget(self, action: #selector(didTappStartRouteBtn), for: .touchUpInside)
        mapView.cancelRouteBtn.addTarget(self, action: #selector(cancelCurrentRoute), for: .touchUpInside)
        mapView.toggleRouteMonitoringModeBtn.addTarget(self, action: #selector(toggleRouteMonitoringMode(_:)), for: .touchUpInside)
        mapView.cancelRouteNavBarBtn.addTarget(self, action: #selector(cancelCurrentRoute), for: .touchUpInside)
    }
    
    private func setNavBar() {
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways else {
            navigationItem.titleView = mapView.turnOnLocationServicesBtn
            return
        }
        
        navigationItem.titleView = nil
    }
    
    private func pushSightDetailView(with sight: SightOnMap) {
        let vc = SightDetailViewController()
        vc.delegate = self
        vc.configure(with: sight)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showOnlySelectedSight(selectedSight sight: SightOnMap) {
        let annotations = viewModel.annotations.filter { $0.title != sight.title }
        mapView.map.removeAnnotations(annotations)
        let overlays = mapView.map.overlays.filter { $0.isKind(of: MKCircle.self) && $0.coordinate.latitude != sight.coordinate.latitude }
        overlays.forEach { mapView.map.removeOverlay($0) }
    }
    
    private func toggleButtonsVisibility(toggle: Bool) {
        if toggle {
            mapView.startRouteBtn.isHidden = true
            mapView.cancelRouteBtn.isHidden = true
        } else {
            mapView.startRouteBtn.isHidden = false
            mapView.cancelRouteBtn.isHidden = false
        }
    }
    
}

//MARK: Objc methods
private extension MapViewController {
    
    @objc func toggleRouteMonitoringMode(_ sender: UIButton) {
        viewModel.isCenteringModeOn.toggle()
    }
    
    @objc func cancelCurrentRoute() {
        viewModel.didStartRoute = false
    }
    
    @objc func didTappStartRouteBtn() {
        viewModel.didStartRoute = true
    }
    
    @objc func requestUserLocation() {
        AlertService().showAlert(type: .turnOnLocation, in: self)
        
        locationManager.requestWhenInUseAuthorization()
    }
}

//MARK: MapViewViewModelDelegate
extension MapViewController: MapViewViewModelDelegate {
    
    func viewModelDidStartRoute(_ viewModel: MapViewViewModel) {
        switch viewModel.didStartRoute {
        case true:
            mapView.toggleRouteMonitoringModeBtn.isHidden = false
            toggleButtonsVisibility(toggle: true)
            navigationItem.leftBarButtonItem = cancelCurrentRouteNavBarItem
        case false:
            mapView.toggleRouteMonitoringModeBtn.isHidden = true
            toggleButtonsVisibility(toggle: true)
            navigationItem.leftBarButtonItem = nil
            viewModel.sightRouteCoordinate = nil
            
            
            self.mapView.map.overlays.forEach {
                if $0.isKind(of: MKPolyline.self) {
                    self.mapView.map.removeOverlay($0)
                }
            }
            
            viewModel.addAnnotationsToMap()
            viewModel.addCircleRadiusToAnnotations()
        }
    }
    
    func viewModelIsCenterModeOn(_ viewModel: MapViewViewModel) {
        switch viewModel.isCenteringModeOn {
        case true:
            guard let userCoordinate = locationManager.location?.coordinate else { return }
            
            let region = viewModel.centerMapOnUserLocation(with: userCoordinate)
            mapView.map.setRegion(region, animated: true)
            mapView.toggleRouteMonitoringModeBtn.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
        case false:
            mapView.toggleRouteMonitoringModeBtn.setImage(UIImage(systemName: "location.fill"), for: .normal)
        }
    }
    
    
    func viewModelDidAddAnnotation(_ viewModel: MapViewViewModel) {
        mapView.map.addAnnotations(viewModel.annotations)
    }
    
    func viewModelDidAddOverlay(_ viewModel: MapViewViewModel) {
        mapView.map.addOverlays(viewModel.overlays)
    }
    
    func viewModelDidUpdateDirection(_ viewModel: MapViewViewModel) {
        
        mapView.map.overlays.filter { $0.isKind(of: MKPolyline.self) }.forEach { mapView.map.removeOverlay($0) }
        
        for route in viewModel.directions {
            mapView.map.addOverlay(route.polyline)
            
            //detach the camera, when route start
            if !viewModel.didStartRoute  {
                mapView.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
        }
    }
}

//MARK: MapDelegate
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
    
    //MARK: DidTap Accessory
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let sight = view.annotation as! SightOnMap
        
        pushSightDetailView(with: sight)
    }
    
    //MARK: OverlayRender
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

//MARK: LocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            
            locationManager.requestWhenInUseAuthorization()
            navigationItem.titleView = mapView.turnOnLocationServicesBtn
            print("notDetermined")
            
        case .restricted:
            
            print("restricted")
            
        case .denied:
            
            AlertService().showAlert(type: .turnOnLocation, in: self)
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
        
    //MARK: UpdateLocation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userCoordinate = locations.first?.coordinate else { return }
        guard let sightCoordinate = viewModel.sightRouteCoordinate else { return }
        
        print(userCoordinate)
        
        let request = viewModel.createDirectionsRequest(from: userCoordinate, to: sightCoordinate)
        let distance = viewModel.calculateDistance(from: userCoordinate, to: sightCoordinate)
        
        print(distance)
        
        //show alert when arrived to end of the road
        if distance <= 80 {
            print("you get to sight safe and sound")
           
            if let sight = viewModel.selectedSight {
                if !CoreDataStack.shared.isSightVisited(sight: sight) {
                    CoreDataStack.shared.saveSight(sight: sight)
                }
            }
            
            cancelCurrentRoute()
            AlertService().showAlert(type: .arrive, in: self)
            return
        }
        
        if viewModel.isCenteringModeOn {
            let region = viewModel.centerMapOnUserLocation(with: userCoordinate)
            mapView.map.setRegion(region, animated: true)
        }
        
        viewModel.calculateDirectionRoute(with: request)
    }
    
}

//MARK: DetailViewDelegate
extension MapViewController: GetRouteDelegate {
    
    func didTapGetRouteBtn(_ coordinate: CLLocationCoordinate2D, _ sight: SightOnMap) {
        guard mapView.map.showsUserLocation else { return }
        guard let userCoordinate = locationManager.location?.coordinate else { return }
        
        showOnlySelectedSight(selectedSight: sight)
        
        viewModel.sightRouteCoordinate = coordinate
        viewModel.selectedSight = sight
        
        let request = viewModel.createDirectionsRequest(from: userCoordinate, to: viewModel.sightRouteCoordinate!)
        viewModel.calculateDirectionRoute(with: request)
        
        toggleButtonsVisibility(toggle: false)
    }
}

