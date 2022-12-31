//
//  SightsTableViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import UIKit
import MapKit

final class SightsTableViewController: UITableViewController {

    private var viewModel = MapViewViewModel()
    private lazy var sights = viewModel.sights
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SightTableViewCell.self, forCellReuseIdentifier: SightTableViewCell.identifier)
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
        
        let vc = SightDetailViewController()
        let sight = SightOnMap(title: sights[indexPath.row].name, coordinate: CLLocationCoordinate2D(latitude: sights[indexPath.row].latitude, longitude: sights[indexPath.row].longitude), subtitle: sights[indexPath.row].subtitle)
        vc.configure(with: sight)
        navigationController?.pushViewController(vc, animated: true)
    }

}
