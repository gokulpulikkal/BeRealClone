//
//  UserAuthViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import ParseSwift

protocol LoginDelegate: AnyObject {
    func didLoginSuccessfully(user: User)
}

class UserAuthViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    weak var delegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Test Remove this
        guard let userName = userNameTextField.text, let password = passwordTextField.text else {
            print("Please enter credentials")
            return
        }
        User.login(username: userName, password: password) { [weak self] result in // Handle the result (of type Result<User, ParseError>)
            switch result {
                case .success(let loggedInUser):
                    self?.userNameTextField.text = nil
                    self?.passwordTextField.text = nil
                    self?.delegate?.didLoginSuccessfully(user: loggedInUser)
                case .failure(let error):
                    print("Failed to log in: \(error.message)")
            }
        }
        
    }
    
    @IBAction func onLoginButtonClick(_ sender: Any) {
        guard let userName = userNameTextField.text, let password = passwordTextField.text else {
            print("Please enter credentials")
            return
        }
        User.login(username: userName, password: password) { [weak self] result in // Handle the result (of type Result<User, ParseError>)
            switch result {
                case .success(let loggedInUser):
                    self?.userNameTextField.text = nil
                    self?.passwordTextField.text = nil
                    self?.delegate?.didLoginSuccessfully(user: loggedInUser)
                case .failure(let error):
                    print("Failed to log in: \(error.message)")
            }
        }
    }
    
    @IBAction func onSignupButtonPress(_ sender: Any) {
        guard let userName = userNameTextField.text, let password = passwordTextField.text else {
            print("Please enter credentials")
            return
        }
        let newUser = User(username: userName, email: "", password: password)
        newUser.signup { [weak self] result in
            switch result {
                case .success(let signedUpUser):
                    self?.userNameTextField.text = nil
                    self?.passwordTextField.text = nil
                    self?.delegate?.didLoginSuccessfully(user: signedUpUser)
                case .failure(let error):
                    print("Failed to Signup: \(error.message)")
            }
        }
    }
    
}
