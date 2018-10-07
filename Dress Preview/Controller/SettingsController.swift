//
//  SettingsController.swift
//  Dress Preview
//
//  Created by Gerald Lim on 15/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Main idea: Using UIPickerView that will only display on button click
    // UserSettings is where the model of the sizes and genders are stored
    let settings = UserSettings()
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!

    // UIPickerView is not shown in storyboard as it needs to be hidden by default
    let genderPicker = UIPickerView()
    let sizePicker = UIPickerView()
    
    // User saved preferences
    var genderSelected: String {
        // return N/D if nothing selected/by default
        return UserDefaults.standard.string(forKey: "genderSelected") ?? "N/D"
    }
    var sizeSelected: String {
        return UserDefaults.standard.string(forKey: "sizeSelected") ?? "N/D"
    }
    
    //MARK:- Image Picker
    @IBAction func imagePickerBtnAction(selectedButton: UIButton)
    {
        // Alerts user to choose from Camera or Gallery to import photo from
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
        // function to open camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            // alert user if no camera is available
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
            // set UIImageView image
            myImageView.image = image
            // set image name so that it can be easily found again
            saveImage(imageName: "profilepic.png")
        }
        else {
            // Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // return image with corresponding name
        getImage(imageName: "profilepic.png")
        genderTextField.text = genderSelected
        sizeTextField.text = sizeSelected
        genderTextField.inputView = genderPicker
        sizeTextField.inputView = sizePicker
        genderPicker.delegate = self
        sizePicker.delegate = self
        print(settings.genders)
        
        // UIPickerView for genders
        if let genderRow = settings.genders.index(of: genderSelected) {
            genderPicker.selectRow(genderRow, inComponent: 0, animated: false)
        }

        // UIPickerView for sizes
        if let sizeRow = settings.sizes.index(of: sizeSelected) {
            sizePicker.selectRow(sizeRow, inComponent: 0, animated: false)
        }

    }
    
    // only show one 'column' of elements since each only has 1 type
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == genderPicker) {
            return settings.genders.count
        }
        else {
            return settings.sizes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == genderPicker) {
            genderTextField.text = settings.genders[row]
            // save user settings into application defaults with keys for identification
            UserDefaults.standard.set(settings.genders[row], forKey: "genderSelected")
        }
        else {
            sizeTextField.text = settings.sizes[row]
            UserDefaults.standard.set(settings.sizes[row], forKey: "sizeSelected")
        }
        
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == genderPicker) {
            return settings.genders[row]
        }
        else {
            return settings.sizes[row]
        }
    }
    
    // function to access files and save image at location
    func saveImage(imageName: String) {
        let fileManager = FileManager.default
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        let image = myImageView.image!
        
        let data = UIImagePNGRepresentation(image)
        
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    
    // function to return image when specified with image name
    func getImage(imageName: String) {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        if fileManager.fileExists(atPath: imagePath) {
            myImageView.image = UIImage(contentsOfFile: imagePath)
        }
        else {
            print("No Image found")
        }
    }
}
