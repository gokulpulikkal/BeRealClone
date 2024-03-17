//
//  LaunchScreenVC.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import ParseSwift

class LaunchScreenVC: BaseViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            if User.current != nil {
                self?.loadHomeViewController()
            } else {
                self?.showAuthenticationView()
            }
        }
    }
    
    func setLogo() {
        let label = UILabel()
        label.text = "BeReal."
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        view.addSubview(label)
        // Set Auto Layout constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
           label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func showAuthenticationView() {
        let authenticationVC = UserAuthViewController()
        authenticationVC.isModalInPresentation = true
        authenticationVC.delegate = self
        present(authenticationVC, animated: true, completion: nil)
    }
    
    func loadHomeViewController() {
        let homeVC = HomeViewController()
        setRootViewController(homeVC)
    }
}

extension LaunchScreenVC: LoginDelegate {
    func didLoginSuccessfully(user: User) {
        print("Login Success for \(user.username ?? "")")
        registerForLocalNotification()
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.loadHomeViewController()
            }
        }
    }
}

