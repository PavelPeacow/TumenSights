//
//  Annotations.swift
//  TumenMustHave
//
//  Created by Павел Кай on 26.10.2022.
//

import Foundation
import MapKit
import UIKit

extension MapViewController {
     func addAnnotationsToMap() {
        print(sights)
        
        for sight in sights {
            let someSight = SightOnMap(title: sight.name, coordinate: CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude), subtitle: sight.subtitle)
            mapView.addAnnotation(someSight)
        }
    }
    
     func addCircleRadiusToAnnotations() {
        for sight in sights {
            let center = CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude)
            let circle = MKCircle(center: center, radius: 80)
            mapView.addOverlay(circle)
        }
    }
}
