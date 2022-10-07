//
//  SightDetailViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import UIKit
import MapKit

protocol GetRouteDelegate {
    func getRouteForMap(_ routes: [MKRoute])
}

class SightDetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = UIScrollView()
    
    var sightCoordinate: CLLocationCoordinate2D?
    var userCoordinate: CLLocationCoordinate2D?
    
    var delegate: GetRouteDelegate?
    
    private let sightImage: UIImageView = {
        let sightImage = UIImageView()
        sightImage.clipsToBounds = true
        sightImage.layer.cornerRadius = 25
        sightImage.contentMode = .scaleAspectFill
        sightImage.translatesAutoresizingMaskIntoConstraints = false
        return sightImage
    }()
    
    private let sightName: UILabel = {
        let sightName = UILabel()
        sightName.translatesAutoresizingMaskIntoConstraints = false
        sightName.numberOfLines = 0
        return sightName
    }()
    
    private let sightDescription: UILabel = {
        let sightDescription = UILabel()
        sightDescription.translatesAutoresizingMaskIntoConstraints = false
        sightDescription.numberOfLines = 0
        return sightDescription
    }()
    
    private lazy var getRouteButton: UIButton = {
        let getRouteButton = UIButton(configuration: UIButton.Configuration.bordered())
        getRouteButton.translatesAutoresizingMaskIntoConstraints = false
        getRouteButton.setTitle("Построит маршрут", for: .normal)
        getRouteButton.addTarget(self, action: #selector(getRoute), for: .touchUpInside)
        return getRouteButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
                
        view.addSubview(scrollView)
        scrollView.addSubview(sightImage)
        scrollView.addSubview(sightName)
        scrollView.addSubview(sightDescription)
        scrollView.addSubview(getRouteButton)
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
    
    public func configure(with model: SightDetail) {
        sightImage.image = UIImage(named: model.name)
        sightName.text = model.name
        sightDescription.text = model.subtitle
        sightCoordinate = model.coordinate
    }
    
    @objc private func getRoute() {

        let request = createDirectionsRequest(from: sightCoordinate!)
        let directions = MKDirections(request: request)
        
        directions.calculate { [weak self] response, error in
            guard let response = response else { print("unable to calculate"); return }

            var routes = [MKRoute]()
            
            for route in response.routes {
                routes.append(route)
            }
            
            self?.delegate?.getRouteForMap(routes)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func createDirectionsRequest(from coordinates: CLLocationCoordinate2D) -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate!))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        request.transportType = .walking
        return request
    }

}

extension SightDetailViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            sightImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            sightImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            sightImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            sightImage.heightAnchor.constraint(equalToConstant: 300),
            
            sightName.topAnchor.constraint(equalTo: sightImage.bottomAnchor, constant: 10),
            sightName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            sightDescription.topAnchor.constraint(equalTo: sightName.bottomAnchor, constant: 15),
            sightDescription.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            sightDescription.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            getRouteButton.topAnchor.constraint(equalTo: sightDescription.bottomAnchor, constant: 15),
            getRouteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getRouteButton.heightAnchor.constraint(equalToConstant: 25),
            getRouteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            getRouteButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
}
