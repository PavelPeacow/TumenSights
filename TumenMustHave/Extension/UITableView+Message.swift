//
//  UITableView+Message.swift
//  TumenMustHave
//
//  Created by Павел Кай on 03.01.2023.
//

import UIKit

extension UITableViewController {
    
    func setEmptyMessageInTableView(_ message: String, _ preferredFont: UIFont.TextStyle) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .systemGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.preferredFont(forTextStyle: preferredFont)
       
        self.tableView.backgroundView = messageLabel;
    }
    
}
