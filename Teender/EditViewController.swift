//
//  EditViewController.swift
//  Teender
//
//  Created by Obiet Panggrahito on 29/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import UIKit
import Firebase

class EditViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var workTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = imageView.frame.width/2
            imageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var changeImageButton: UIButton! {
        didSet {
            changeImageButton.addTarget(self, action: #selector(uploadPhotoButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!
    var currentUserID : String = ""
    
    var username : String = ""
    var work : String = ""
    var imageURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        setup()
    }
    
    func setup () {
        
        self.usernameTextField.text = username
        self.workTextField.text = work
        self.imageView.loadImageUsingCacheWithUrlString(urlString: imageURL)
    }
    
    func doneButtonTapped () {
        
        guard
            let username = usernameTextField.text,
            let work = workTextField.text
            else { return }
        
        let updateProfile : [String : String] = ["username" : username, "work" : work]
        ref.child("users").child(currentUserID).child("profile").updateChildValues(updateProfile)
        dismiss(animated: true, completion: nil)
    }
    
    func uploadPhotoButtonTapped () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func dismissImagePicker() {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage) {
        
        let ref = Storage.storage().reference().child("profile_images").child("\(currentUserID).jpeg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5)
            else {return}
        
        ref.putData(imageData, metadata: nil, completion: { (meta, error) in
            if let downloadPath = meta?.downloadURL()?.absoluteString { // bug : meta is nil
                self.saveImagePath(downloadPath)
            }
        })
    }
    
    func createTimeStamp() -> String {
        
        let currentDate = NSDate()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        let timeCreated = dateFormatter.string(from: currentDate as Date)
        
        return timeCreated
        
    }
    
    func saveImagePath(_ path: String) {
        
        let profileValue : [String: Any] = ["imageURL": path]
        ref.child("users").child(currentUserID).child("profile").updateChildValues(profileValue)
    }
    
    func uniqueFileForUser(_ name: String) -> String {
        let currentDate = Date()
        return "\(name)_\(currentDate.timeIntervalSince1970).jpeg"
    }
}

extension EditViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer { dismissImagePicker() }
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
            
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imageView.image = selectedImage
            uploadImage(selectedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
        dismiss(animated: true, completion: nil)
    }
}
