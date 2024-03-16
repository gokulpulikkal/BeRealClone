//
//  BaseViewController.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import UIKit
import PhotosUI

class BaseViewController: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
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
            self.present(cameraImagePicker, animated: true) {
                
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
        guard let assetId = result?.assetIdentifier, let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
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
        guard let image = info[.originalImage] as? UIImage else {
            // Handle case where image is not available
            return
        }
        if let mediaMetadata = info[.mediaMetadata] as? [String: Any] {
            // Extract location from media metadata if available
            if let gpsInfo = mediaMetadata["{GPS}"] as? [String: Any],
               let latitude = gpsInfo["Latitude"] as? CLLocationDegrees,
               let longitude = gpsInfo["Longitude"] as? CLLocationDegrees {
            }
        }
        if #available(iOS 11.0, *) {
            if let asset = info[.phAsset] as? PHAsset, let location = asset.location {
                self.onGettingPhotoFromDevice(image, location)
            }
        } else {
            if let assetURL = info[.referenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil)
                if let asset = result.firstObject, let location = asset.location {
                    self.onGettingPhotoFromDevice(image, location)
                }
            }
        }
        self.onGettingPhotoFromDevice(image, nil)
    }
}
