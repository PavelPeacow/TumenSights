//
//  SightModel.swift
//  TumenMustHave
//
//  Created by Павел Кай on 29.09.2022.
//

import Foundation
import MapKit

struct Sight: Codable {
    let name: String
    let subtitle: String
    
    let latitude: Double
    let longitude: Double
}

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
