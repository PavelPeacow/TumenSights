//
//  SightDetailViewController.swift
//  TumenMustHave
//
//  Created by Павел Кай on 06.10.2022.
//

import UIKit

class SightDetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let sightImage: UIImageView = {
        let sightImage = UIImageView()
        sightImage.contentMode = .scaleAspectFit
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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(sightImage)
        scrollView.addSubview(sightName)
        scrollView.addSubview(sightDescription)
        setConstraints()
    }
    
    public func configure(with model: SightDetail) {
        sightImage.image = UIImage(named: model.name)
        sightName.text = model.name
        sightDescription.text = model.subtitle
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }

}

extension SightDetailViewController {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            sightImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            sightImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            sightImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            sightImage.heightAnchor.constraint(equalToConstant: 200),
            
            sightName.topAnchor.constraint(equalTo: sightImage.bottomAnchor, constant: 10),
            sightName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            sightDescription.topAnchor.constraint(equalTo: sightName.bottomAnchor, constant: 15),
            sightDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            sightDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            sightDescription.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
}
