//
//  ViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 29.09.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    private var sights = [Sight]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "loh")
        return tableView
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(mapView)
        
        addAnnotationsToMap()

        setDelegates()
    }
    
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        mapView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        mapView.frame = view.bounds
    }
    
    private func addAnnotationsToMap() {
        
        sights = JsonDecoder.shared.getJsonData() ?? []
        print(sights)
        
        for sight in sights {
            
            let someSight = SightOnMap(title: sight.name, coordinate: CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude), subtitle: sight.name)
                mapView.addAnnotation(someSight)
            
        }
    }
    
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loh", for: indexPath)
        
        cell.textLabel?.text = sights[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is SightOnMap else { return nil }
        
        let identifier = "Sight"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = .green
            
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
       
        
        return annotationView
    }
}
