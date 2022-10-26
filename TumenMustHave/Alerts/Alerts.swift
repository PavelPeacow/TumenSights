//
//  Alerts.swift
//  TumenMustHave
//
//  Created by Павел Кай on 07.10.2022.
//

import Foundation
import UIKit

extension UIViewController {
    func showTurnUserLocationOnDeviceAlert() {
        let alert = UIAlertController(title: "Turn on Location Services", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
               if UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
               }
            }
            print("settings")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}


