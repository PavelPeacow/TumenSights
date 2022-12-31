//
//  SightTableViewCell.swift
//  TumenMustHave
//
//  Created by Павел Кай on 09.10.2022.
//

import UIKit

final class SightTableViewCell: UITableViewCell {

    static let identifier = "SightTableViewCell"
    
    private let sightImage: UIImageView = {
        let sightImage = UIImageView()
        sightImage.translatesAutoresizingMaskIntoConstraints = false
        sightImage.layer.cornerRadius = 25
        sightImage.contentMode = .scaleAspectFill
        sightImage.clipsToBounds = true
        return sightImage
    }()
    
    private let sightTitle: UILabel = {
        let sightTitle = UILabel()
        sightTitle.translatesAutoresizingMaskIntoConstraints = false
        sightTitle.numberOfLines = 0
        return sightTitle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(sightImage)
        contentView.addSubview(sightTitle)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with sightName: String) {
        sightTitle.text = sightName
        sightImage.image = UIImage(named: sightName)
    }

}

extension SightTableViewCell {
    func setConstraints() {
        NSLayoutConstraint.activate([
            sightImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            sightImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sightImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            sightImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45),
            
            sightTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sightTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            sightTitle.leadingAnchor.constraint(equalTo: sightImage.trailingAnchor, constant: 15),
        ])
    }
}
