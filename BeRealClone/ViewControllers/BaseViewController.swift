//
//  BaseViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import PhotosUI
import CoreLocation
import UserNotifications

class BaseViewController: UIViewController, UINavigationControllerDelegate {
    
    private let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        locationManager.delegate = self
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    func makeRequestForAuthorizationNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func registerForLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Let's BeReal Now"
        content.subtitle = "Take a photo and share it with friends"
        content.sound = UNNotificationSound.default
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*12, repeats: false)

        // add our notification request
        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                // handle error
                print(error)
            }
        }
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func startCapturingUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
    
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
    
    // MARK: Photo picker related codes
    func showImagePickerOptions() {
        let alertVC = UIAlertController(title: "Select your profile photo", message: "choose the source from which you wanna load you amazing photo", preferredStyle: .actionSheet)
        // option for camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            let cameraImagePicker = imagePicker(sourceType: .camera)
            if PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .authorized {
                PHPhotoLibrary.requestAuthorization { [weak self](_) in
                    // Present the UIImagePickerController
                    DispatchQueue.main.async {
                        self?.present(cameraImagePicker, animated: true, completion: nil)
                    }
                }
            }
        }
        // Chose from gallery
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            
            var configuration = PHPickerConfiguration.init(photoLibrary: .shared())
            //0 - unlimited 1 - default
            configuration.selectionLimit = 1
            configuration.filter = .images
            let pickerViewController = PHPickerViewController(configuration: configuration)
            pickerViewController.delegate = self
            present(pickerViewController, animated: true)
        }
        //Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = sourceType
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        return imagePickerVC
    }
    
    // Inheriting views has to override this function
    func onGettingPhotoFromDevice(_ selectedImage: UIImage, _ location: CLLocation?) {
        
    }
    
}
extension BaseViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let result = results.first
        var location = userLocation
        if let assetId = result?.assetIdentifier, let photoLocation = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location {
            location = photoLocation
        }
        if let itemProvider = result?.itemProvider {
            if itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { image , error  in
                    if let error{
                        print(error)
                    }
                    if let selectedImage = image as? UIImage{
                        DispatchQueue.main.async { [weak self] in
                            self?.onGettingPhotoFromDevice(selectedImage, location)
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            // Handle case where image is not available
            return
        }
        self.onGettingPhotoFromDevice(image, userLocation)
    }
}

extension BaseViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] // The first location in the array
    }
}
