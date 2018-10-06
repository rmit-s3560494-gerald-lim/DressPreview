//
//  ImportFavouritesController.swift
//  Dress Preview
//
//  Created by Gerald Lim on 5/10/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit

class ImportFavouritesController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var nameFav: UITextField!
    
    // Connect to Favourites Model
//    var favourites = Favourites.init(images: <#T##[Image]?#>, names: <#T##[String]?#>)
    // TODO: save images to UIIMage array?
    // Save images with name
    @IBOutlet weak var saveNow: UIBarButtonItem!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var namingFav: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // disables save function until conditions are met
        self.saveNow.isEnabled = false
        
        
//        newFav.append(imageToAdd)
//        newFavName.append(imageName)
        
    }
    //MARK:- Image Picker
    @IBAction func imagePickerBtnAction(selectedButton: UIButton)
    {
        
        let alert = UIAlertController(title: "Import Image From", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.importImage((Any).self)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "No camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // import image function
    @IBAction func importImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        self.present(image, animated: true) {
            // after completion
        }
    }
    
    // Setting UIImageView as picture imported
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let image = chosenImage {
            myImageView.image = image
        }
        else {
            // Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
extension FavouritesViewController {
    @IBAction func unwindToFavouritesViewController(_ segue: UIStoryboardSegue){
        
    }
//    @IBAction func saveToFavourites(_ segue: UIStoryboardSegue) {
//
//
//    }
}
