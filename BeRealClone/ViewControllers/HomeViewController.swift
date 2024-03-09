//
//  HomeViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Be Real"
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutUser))
        // Set the back button for the next view controller
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func logoutUser() {
        User.logout { [weak self] result in
            switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Failed to log out: \(error.message)")
            }
        }
    }
}
