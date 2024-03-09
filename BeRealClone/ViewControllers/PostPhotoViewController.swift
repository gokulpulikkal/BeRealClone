//
//  PostPhotoViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import PhotosUI
import ParseSwift

class PostPhotoViewController: UIViewController {

    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let postButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postPhoto))
        self.navigationItem.rightBarButtonItem = postButton
    }
    
    @IBAction func onSelectPhotoButtonClick(_ sender: Any) {
        let alertVC = UIAlertController(title: "Select your photo", message: "choose the source from which you wanna load your amazing photo", preferredStyle: .actionSheet)
                let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] (action) in
                    guard let self = self else { return }
                    
                    var configuration = PHPickerConfiguration.init(photoLibrary: .shared())
                    configuration.filter = .images
                    let pickerViewController = PHPickerViewController(configuration: configuration)
                    pickerViewController.delegate = self
                    present(pickerViewController, animated: true)
                }
                //Cancel action
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertVC.addAction(galleryAction)
                alertVC.addAction(cancelAction)
                self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func postPhoto() {
        guard let image = imageView.image, let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let caption = captionTextField.text ?? ""
        
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        var post = Post()
        post.imageFile = imageFile
        post.caption = caption
        post.user = User.current
        post.save { [weak self] result in

            // Switch to the main thread for any UI updates
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

}

extension PostPhotoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider{
            if itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { image , error  in
                    if let error{
                        print(error)
                    }
                    if let selectedImage = image as? UIImage{
                        DispatchQueue.main.async { [weak self] in
                            self?.imageView.image = selectedImage
                        }
                    }
                }
            }
        }
        
    }
}
