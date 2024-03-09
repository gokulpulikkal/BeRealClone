//
//  BaseViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit

class BaseViewController: UIViewController {
    // Common functions or properties can be added here
    
    // Function to set root view controller from any view controller
    func setRootViewController(_ viewController: UIViewController) {
        // Check if the current view controller is already embedded in a navigation controller
        if let navigationController = self.navigationController {
            navigationController.setViewControllers([viewController], animated: true)
        } else {
            // If not embedded in a navigation controller, use the window scene approach
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate else {
                return
            }
            
            let window = sceneDelegate.window
            let navigationController = UINavigationController(rootViewController: viewController)
            window?.rootViewController = navigationController
        }
    }
}

