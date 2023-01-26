//
//  AlertService.swift
//  TumenMustHave
//
//  Created by Павел Кай on 03.01.2023.
//

import UIKit

enum AlertType {
    case arrive
    case turnOnLocation
    case emptyTable
}

final class AlertService: UIViewController {
    
    private var targetViewController: UIViewController!
    
    private lazy var alertBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isUserInteractionEnabled = false
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
        
        return view
    }()
    
    private lazy var alertLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackViewBtns: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [okBtn, settingsBtn])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var okBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Oк!", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        return btn
    }()
    
    private lazy var settingsBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Настройки", for: .normal)
        btn.isHidden = true
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.6)
        
        view.addSubview(alertBackground)
        alertBackground.addSubview(alertLabel)
        alertBackground.addSubview(stackViewBtns)
        
        setConstraints()
    }
    
    func showAlert(type: AlertType, in viewController: UIViewController) {

        targetViewController = viewController
        
        switch type {
        case .arrive:
            alertLabel.text = "Вы достигли отмеченной достопримечательности!"
        case .turnOnLocation:
            settingsBtn.isHidden = false
            alertLabel.text = "Включите отслеживание, чтобы пользоваться картами в полной мере!"
        case .emptyTable:
            okBtn.isHidden = true
            settingsBtn.isHidden = true
            alertLabel.text = "Посещенные достопримечательности будут отображены здесь!"
        }
        
        targetViewController.addChild(self)
        self.view.frame = targetViewController.view.frame
        targetViewController.view.addSubview(self.view)
        self.didMove(toParent: targetViewController)
        targetViewController.navigationController?.navigationBar.isUserInteractionEnabled = false
        moveIn()
    }
        
    private func moveIn() {
        self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.24) {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }
    }
    
    private func moveOut() {
        UIView.animate(withDuration: 0.24, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            self.view.alpha = 0.0
        }) { _ in
            self.targetViewController.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.view.removeFromSuperview()
        }
    }
    
}

private extension AlertService {
    
    @objc func goToSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
           if UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           }
        }
    }
    
    @objc func dismissAlert() {
        moveOut()
    }
}

extension AlertService {
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            alertBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertBackground.bottomAnchor.constraint(equalTo: stackViewBtns.bottomAnchor, constant: 15),
            alertBackground.widthAnchor.constraint(equalToConstant: 280),
            
            alertLabel.topAnchor.constraint(equalTo: alertBackground.topAnchor, constant: 5),
            alertLabel.leadingAnchor.constraint(equalTo: alertBackground.leadingAnchor, constant: 10),
            alertLabel.trailingAnchor.constraint(equalTo: alertBackground.trailingAnchor, constant: -10),
            
            stackViewBtns.topAnchor.constraint(equalTo: alertLabel.bottomAnchor, constant: 10),
            stackViewBtns.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackViewBtns.leadingAnchor.constraint(equalTo: alertBackground.leadingAnchor, constant: 10),
            stackViewBtns.trailingAnchor.constraint(equalTo: alertBackground.trailingAnchor, constant: -10),
        ])
    }
    
}
