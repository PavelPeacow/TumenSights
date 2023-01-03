//
//  SightsTableViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import UIKit
import CoreData
import MapKit

final class SightsTableViewController: UITableViewController {

    private lazy var sights = CoreDataStack.shared.fetchSights()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SightTableViewCell.self, forCellReuseIdentifier: SightTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sights = CoreDataStack.shared.visitedSights
        tableView.reloadData()
        
        checkForEmptyTable()
    }
    
    private func pushSightDetailView(sight: Sight) {
        let vc = SightDetailViewController()
        let coordinate = CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude)
        let sight = SightOnMap(title: sight.name, coordinate: coordinate, subtitle: sight.subtitle)
        vc.configure(with: sight)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func checkForEmptyTable() {
        if sights.isEmpty { setEmptyMessageInTableView("Посещенные достопримечательности будут отображены здесь", .headline) }
        else { tableView.backgroundView = nil }
    }
    
}

extension SightsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SightTableViewCell.identifier, for: indexPath) as! SightTableViewCell
        
        cell.configure(with: sights[indexPath.row].name)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        220
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        pushSightDetailView(sight: sights[indexPath.row])
    }

}
