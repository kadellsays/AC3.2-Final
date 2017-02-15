//
//  UploadViewController.swift
//  AC3.2-Final
//
//  Created by Kadell on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePickedView: UIImageView!    
    @IBOutlet weak var descriptionTextField: UITextView!
    
    var databaseReference: FIRDatabaseReference!
    var storageReference: FIRStorageReference!
    var userUID: String!
    var currentImage = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.databaseReference = FIRDatabase.database().reference().child("posts")
        self.storageReference = FIRStorage.storage().reference(forURL: "gs://ac-32-final.appspot.com")
        userUID = FIRAuth.auth()?.currentUser?.uid
        descriptionTextField.layer.borderWidth = 1.0
        
    }

    
    func shareToFirebase() {
       
            let linkRef = self.databaseReference.childByAutoId()
        
            let post = Post(key: linkRef.key, comment: descriptionTextField.text!, userId: userUID)
            let dict = post.asDictionary
        
            linkRef.setValue(dict) { (error, reference) in
                
                if let error = error {
                    let alertController = UIAlertController(title: "Upload Failed!!", message: "\(error)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                else {
                    
                    let storRef = self.storageReference.child("images/\(linkRef.key)")
                    
                    let jpeg = UIImageJPEGRepresentation(self.currentImage, 0.5)
                    
                    
                    let metadata = FIRStorageMetadata()
                    metadata.cacheControl = "public,max-age=300";
                    metadata.contentType = "image/jpeg";
                    
                    if let jpegUnwrapped = jpeg {
                    let _ = storRef.put(jpegUnwrapped, metadata: metadata) { (metadata, error) in
                        guard metadata != nil else {
                            print("put error")
                            return
                        }
                    }
                    
                    
                    let alertController = UIAlertController(title: "Photo uploaded!", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        
    }
    


    
    //MARK: -ImagePickerDelegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[" UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imagePickedView.contentMode = .scaleAspectFill
            imagePickedView.image = selectedImage
            currentImage = selectedImage
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Actions
    @IBAction func imageViewPressed(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [ String(kUTTypeImage) ]
        imagePickerController.delegate = self
        
        self.present(imagePickerController, animated: true, completion:  nil)
        
    }
    
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        shareToFirebase()
    }
    
    

}
