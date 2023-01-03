//
//  MapViewViewModel.swift
//  TumenMustHave
//
//  Created by Павел Кай on 30.12.2022.
//

import UIKit
import MapKit

protocol MapViewViewModelDelegate {
    func viewModelDidStartRoute(_ viewModel: MapViewViewModel)
    func viewModelIsCenterModeOn(_ viewModel: MapViewViewModel)
    
    func viewModelDidAddAnnotation(_ viewModel: MapViewViewModel)
    func viewModelDidAddOverlay(_ viewModel: MapViewViewModel)
    func viewModelDidUpdateDirection(_ viewModel: MapViewViewModel)
}

final class MapViewViewModel {
    
    private var sights = [Sight]()
    
    var overlays = [MKCircle]()
    var annotations = [SightOnMap]()
    var directions = [MKRoute]()
    
    var sightRouteCoordinate: CLLocationCoordinate2D?
    var selectedSight: SightOnMap?
    
    var delegate: MapViewViewModelDelegate?
    
    var didStartRoute = false {
        didSet {
            delegate?.viewModelDidStartRoute(self)
        }
    }
    var isCenteringModeOn = false {
        didSet {
            delegate?.viewModelIsCenterModeOn(self)
        }
    }
        
    init() {
        sights = getSights()
    }
    
    private func getSights() -> [Sight] {
        do {
            let sights = try JsonDecoder().getJsonData(with: JsonConstant.fileURL)
            return sights
        } catch {
            print(error)
            return []
        }
    }
    
    func addAnnotationsToMap() {
        for sight in sights {
            let someSight = SightOnMap(title: sight.name, coordinate: CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude), subtitle: sight.subtitle)
            annotations.append(someSight)
        }
        delegate?.viewModelDidAddAnnotation(self)
    }
    
    func addCircleRadiusToAnnotations() {
        for sight in sights {
            let center = CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude)
            let circle = MKCircle(center: center, radius: 80)
            overlays.append(circle)
        }
        delegate?.viewModelDidAddOverlay(self)
    }
    
    func centerMapCamera() -> MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 57.148470, longitude: 65.549138)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        return region
    }
    
    func centerMapOnUserLocation(with userCoordinate: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        return region
    }
    
    func createDirectionsRequest(from userCoordinate: CLLocationCoordinate2D, to sightCoordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let sourse = MKPlacemark(coordinate: userCoordinate)
        let destination = MKPlacemark(coordinate: sightCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourse)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        return request
    }
    
    func calculateDistance(from userCoordinate: CLLocationCoordinate2D, to sightCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let sightLocation = CLLocation(latitude: sightCoordinate.latitude, longitude: sightCoordinate.longitude)
        
        let distanse = userLocation.distance(from: sightLocation)
        return distanse
    }
    
    func calculateDirectionRoute(with request: MKDirections.Request) {
        let request = request
        let directions = MKDirections(request: request)
        
        directions.cancel()
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let response = response else {
                print("unable to calculate")
                return
            }
            
            self.directions = response.routes
            self.delegate?.viewModelDidUpdateDirection(self)
        }
    }
    
}
