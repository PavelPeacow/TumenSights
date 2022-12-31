//
//  SightDetailViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import UIKit
import MapKit
import CoreData

protocol GetRouteDelegate {
    func getSightCoordinates(_ coordinate: CLLocationCoordinate2D, _ sight: SightOnMap)
}

class SightDetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = UIScrollView()
    
    var sightCoordinate: CLLocationCoordinate2D?
    var selectedSigth: SightOnMap?
    
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
        getRouteButton.setTitle("Построить маршрут", for: .normal)
        getRouteButton.addTarget(self, action: #selector(getRoute), for: .touchUpInside)
        return getRouteButton
    }()
    
    private lazy var markAsVisitedSightBtn: UIButton = {
        let btn = UIButton(configuration: UIButton.Configuration.bordered())
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Отметить как посещенное", for: .normal)
        btn.addTarget(self, action: #selector(markAsVisitedSight), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(CoreDataStack.shared.fetchSights())
        
        view.backgroundColor = .systemBackground
                
        view.addSubview(scrollView)
        scrollView.addSubview(sightImage)
        scrollView.addSubview(sightName)
        scrollView.addSubview(sightDescription)
        scrollView.addSubview(getRouteButton)
        scrollView.addSubview(markAsVisitedSightBtn)
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
    
    public func configure(with model: SightOnMap) {
        sightImage.image = UIImage(named: model.title ?? "")
        sightName.text = model.title
        sightDescription.text = model.subtitle
        sightCoordinate = model.coordinate
        selectedSigth = model
    }
    
    @objc private func getRoute() {
        guard let sightCoordinate = sightCoordinate else { return }
        guard let sight = selectedSigth else { return }
        delegate?.getSightCoordinates(sightCoordinate, sight)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func markAsVisitedSight() {
        guard let selectedSigth = selectedSigth else { return }
        guard !CoreDataStack.shared.isSightVisited(sight: selectedSigth) else { return }
        
        CoreDataStack.shared.saveSight(sight: selectedSigth)
        navigationController?.popViewController(animated: true)
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
            
            markAsVisitedSightBtn.topAnchor.constraint(equalTo: getRouteButton.bottomAnchor, constant: 15),
            markAsVisitedSightBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            markAsVisitedSightBtn.heightAnchor.constraint(equalToConstant: 25),
            markAsVisitedSightBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            markAsVisitedSightBtn.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
}
