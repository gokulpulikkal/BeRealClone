//
//  LaunchScreenVC.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import ParseSwift

class LaunchScreenVC: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAuthenticationView()
    }
    
    func showAuthenticationView() {
        let authenticationVC = UserAuthViewController()
        authenticationVC.isModalInPresentation = true
        authenticationVC.delegate = self
        present(authenticationVC, animated: true, completion: nil)
    }
    
    func loadHomeViewController() {
        let homeVC = HomeViewController()

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }

        let window = sceneDelegate.window
        let navigationController = UINavigationController(rootViewController: homeVC)
        window?.rootViewController = navigationController
    }
    
}

extension LaunchScreenVC: LoginDelegate {
    func didLoginSuccessfully(user: User) {
        print("Login Success for \(user.username ?? "")")
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.loadHomeViewController()
            }
        }
    }
}

