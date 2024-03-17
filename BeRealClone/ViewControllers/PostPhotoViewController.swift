//
//  PostPhotoViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import PhotosUI
import ParseSwift
import MapKit


class PostPhotoViewController: BaseViewController {

    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCapturingUserLocation()
        let postButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postPhoto))
        self.navigationItem.rightBarButtonItem = postButton
    }
    
    @IBAction func onSelectPhotoButtonClick(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                print("Authorized")
            default:
                print("No aithorization")
            }
        }
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
        getLocationName { locationName in
            if let locationName = locationName {
                post.locationName = locationName
            }
            post.save { [weak self] result in

                // Switch to the main thread for any UI updates
                DispatchQueue.main.async {
                    switch result {
                    case .success(let post):
                        print("✅ Post Saved! \(post)")
                        self?.removeAllPendingNotifications()
                        self?.registerForLocalNotification()
                        self?.updateUserLastPhotoUploadTime()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getLocationName(completion: @escaping (String?) -> Void) {
        guard let location = location else { 
            completion(nil)
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed with error: \(error.localizedDescription)")
                completion(nil) // Call completion handler with nil to indicate failure
                return
            }

            // Check if any placemarks were found
            if let placemark = placemarks?.first {
                // Access location name from the placemark
                let locationName = placemark.name ?? ""
                print("Location name: \(locationName)")
                completion(locationName) // Call completion handler with location name
                return
                
                // You can also access other address components such as locality, administrativeArea, etc.
                // let locality = placemark.locality ?? ""
                // let administrativeArea = placemark.administrativeArea ?? ""
                // ...
            } else {
                print("No placemarks found")
                completion(nil) // Call completion handler with nil if no placemarks were found
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
    
    
    
    override func onGettingPhotoFromDevice(_ selectedImage: UIImage, _ location: CLLocation?) {
        self.imageView.image = selectedImage
        self.location = location
    }
}
