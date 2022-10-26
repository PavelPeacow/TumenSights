//
//  MapCamera.swift
//  TumenMustHave
//
//  Created by Павел Кай on 26.10.2022.
//

import Foundation
import UIKit
import MapKit

extension MapViewController {
     func centerMapOnUserLocation(with userCoordinate: CLLocationCoordinate2D) {
        guard isCenteringModeOn else { return }
        let center = CLLocationCoordinate2D(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
    }
    
     func centerMapCamera() {
        let coordinate = CLLocationCoordinate2D(latitude: 57.148470, longitude: 65.549138)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
