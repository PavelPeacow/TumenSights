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

        let map = UINavigationController(rootViewController: ViewController())
        let table = UINavigationController(rootViewController: SightsTableViewController())
        
        map.tabBarItem.title = "Map"
        map.tabBarItem.image = UIImage(systemName: "map")
        
        table.tabBarItem.title = "Sights"
        table.tabBarItem.image = UIImage(systemName: "list.dash")
        
        tabBarController?.tabBar.tintColor = .systemBackground
        
        
        setViewControllers([map, table], animated: true)
    }
}
