//
//  CoreDataStack.swift
//  TumenMustHave
//
//  Created by Павел Кай on 31.12.2022.
//

import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    var visitedSights: [Sight] = [Sight]()
    
    private init() {
        visitedSights = fetchSights()
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VisitedSights")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveSight(sight: SightOnMap) {
        let context = persistentContainer.viewContext
        
        let object = VisitedSightEntity(context: context)
        object.title = sight.title
        object.subtitle = sight.subtitle
        object.longitude = sight.coordinate.longitude
        object.latitude = sight.coordinate.latitude
        
        do {
            try context.save()
            visitedSights = fetchSights()
        } catch {
            print(error)
        }
    }
    
    func isSightVisited(sight: SightOnMap) -> Bool {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<VisitedSightEntity> = VisitedSightEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", sight.title!)
        
        do {
            let objects = try context.fetch(request)
            
            guard let _ = objects.first else { return false }
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func deleteSight(sight: SightOnMap) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<VisitedSightEntity> = VisitedSightEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", sight.title!)
        
        do {
            let objects = try context.fetch(request)

            if let objectToDelete = objects.first {
                context.delete(objectToDelete)
                try context.save()
                visitedSights = fetchSights()
            }
        } catch {
            print(error)
        }
    }
    
    func fetchSights() -> [Sight] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<VisitedSightEntity> = VisitedSightEntity.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        var sights = [Sight]()
        
        do {
            let result = try context.fetch(request)
            for data in result {
                let title = data.value(forKey: "title") as! String
                let subtitle = data.value(forKey: "subtitle") as! String
                let latitude = data.value(forKey: "latitude") as! Double
                let longitude = data.value(forKey: "longitude") as! Double
                
                let sight = Sight(name: title, subtitle: subtitle, latitude: latitude, longitude: longitude)
                sights.append(sight)
            }
        } catch {
            print(error)
        }
        
        return sights
    }
    
}
