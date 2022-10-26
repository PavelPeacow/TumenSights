//
//  Directions.swift
//  TumenMustHave
//
//  Created by Павел Кай on 26.10.2022.
//

import Foundation
import MapKit
import UIKit

extension MapViewController {
    func createDirectionsRequest(from userCoordinate: CLLocationCoordinate2D, to coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let sourse = MKPlacemark(coordinate: userCoordinate)
        let destination = MKPlacemark(coordinate: coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourse)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        return request
    }
    
    func calculateDistance(userCoordinate: CLLocationCoordinate2D, sightCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let sightLocation = CLLocation(latitude: sightCoordinate.latitude, longitude: sightCoordinate.longitude)
        
        let distanse = userLocation.distance(from: sightLocation)
        return distanse
    }
    
    func calculateDirectionRoute(with request: MKDirections.Request) {
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
}
