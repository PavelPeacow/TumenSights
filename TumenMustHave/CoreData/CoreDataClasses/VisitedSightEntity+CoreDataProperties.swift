//
//  VisitedSightEntity+CoreDataProperties.swift
//  TumenMustHave
//
//  Created by Павел Кай on 31.12.2022.
//
//

import Foundation
import CoreData


extension VisitedSightEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VisitedSightEntity> {
        return NSFetchRequest<VisitedSightEntity>(entityName: "VisitedSightEntity")
    }

    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension VisitedSightEntity : Identifiable {

}
