//
//  MainTabBarController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let map = UINavigationController(rootViewController: MapViewController())
        let table = UINavigationController(rootViewController: SightsTableViewController())
        
        map.tabBarItem.title = "Карта"
        map.tabBarItem.image = UIImage(systemName: "map")
        
        table.tabBarItem.title = "Посещенные места"
        table.tabBarItem.image = UIImage(systemName: "list.dash")
        
        tabBarController?.tabBar.tintColor = .systemBackground
        
        
        setViewControllers([map, table], animated: true)
    }
}
