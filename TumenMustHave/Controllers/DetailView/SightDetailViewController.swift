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
    func didTapGetRouteBtn(_ coordinate: CLLocationCoordinate2D, _ sight: SightOnMap)
}

final class SightDetailViewController: UIViewController {
    
    var detailView = SightDetailView()
    
    var sightCoordinate: CLLocationCoordinate2D!
    var selectedSight: SightOnMap!
    
    var delegate: GetRouteDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setTargets()
    }
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        detailView.scrollView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CoreDataStack.shared.isSightVisited(sight: selectedSight) {
            setButtonsVisibility(isSightVisited: true)
        } else {
            setButtonsVisibility(isSightVisited: false)
        }
    }
    
    private func setTargets() {
        detailView.getRouteBtn.addTarget(self, action: #selector(getRoute), for: .touchUpInside)
        detailView.markAsVisitedSightBtn.addTarget(self, action: #selector(markAsVisitedSight), for: .touchUpInside)
        detailView.unmarkAsVisitedSightBtn.addTarget(self, action: #selector(unmarkAsVisitedSight), for: .touchUpInside)
    }
    
    func configure(with model: SightOnMap) {
        detailView.sightImage.image = UIImage(named: model.title ?? "")
        detailView.sightName.text = model.title
        detailView.sightDescription.text = model.subtitle
        
        sightCoordinate = model.coordinate
        selectedSight = model
    }
    
    private func setButtonsVisibility(isSightVisited toggle: Bool) {
        if toggle {
            detailView.unmarkAsVisitedSightBtn.isHidden = false
            detailView.markAsVisitedSightBtn.isHidden = true
        } else {
            detailView.unmarkAsVisitedSightBtn.isHidden = true
            detailView.markAsVisitedSightBtn.isHidden = false
        }
    }
    
    private func setRouteFromTableView() {
        let navController = tabBarController?.viewControllers?.first
        if let navigation = navController as? UINavigationController {
            let vc = navigation.viewControllers[0] as? MapViewController
            self.delegate = vc
            delegate?.didTapGetRouteBtn(sightCoordinate, selectedSight)
            tabBarController?.selectedIndex = 0
        }
    }
    
    private func isLocationEnabled() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .denied:
            return false
        case .restricted, .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    }
        
}

private extension SightDetailViewController {
    
    @objc private func getRoute() {
        
        guard isLocationEnabled() else {
            AlertService().showAlert(type: .turnOnLocation, in: self)
            return
        }
        
        if let delegate = delegate {
            delegate.didTapGetRouteBtn(sightCoordinate, selectedSight)
        } else {
            setRouteFromTableView()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func markAsVisitedSight() {
        guard !CoreDataStack.shared.isSightVisited(sight: selectedSight) else { return }
        
        CoreDataStack.shared.saveSight(sight: selectedSight)
        setButtonsVisibility(isSightVisited: true)
    }
    
    @objc private func unmarkAsVisitedSight() {
        guard CoreDataStack.shared.isSightVisited(sight: selectedSight) else { return }
        
        CoreDataStack.shared.deleteSight(sight: selectedSight)
        setButtonsVisibility(isSightVisited: false)
    }
}
