//
//  MapKitSightModel.swift
//  TumenMustHave
//
//  Created by Павел Кай on 31.12.2022.
//

import MapKit

class SightOnMap: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
