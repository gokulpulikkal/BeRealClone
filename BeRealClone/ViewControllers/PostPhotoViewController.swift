//
//  PostPhotoViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import PhotosUI
import ParseSwift

class PostPhotoViewController: BaseViewController {

    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let postButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postPhoto))
        self.navigationItem.rightBarButtonItem = postButton
    }
    
    @IBAction func onSelectPhotoButtonClick(_ sender: Any) {
        showImagePickerOptions()
    }
    
    @objc func postPhoto() {
        guard let currentUser = User.current, let image = imageView.image, let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let caption = captionTextField.text ?? ""
        
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        var post = Post()
        post.imageFile = imageFile
        post.caption = caption
        post.user = currentUser
        post.save { [weak self] result in

            // Switch to the main thread for any UI updates
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")
                    self?.updateUserLastPhotoUploadTime()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateUserLastPhotoUploadTime() {
        guard var currentUser = User.current else { return }
        // Update the `lastPostedDate` property on the user with the current date.
        currentUser.lastPostedDate = Date()

        // Save updates to the user (async)
        currentUser.save { [weak self] result in
            switch result {
            case .success(let user):
                print("✅ User Saved! \(user)")
                // Switch to the main thread for any UI updates
                DispatchQueue.main.async {
                    // Return to previous view controller
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func onGettingPhotoFromDevice(_ selectedImage: UIImage) {
        self.imageView.image = selectedImage
    }
}
