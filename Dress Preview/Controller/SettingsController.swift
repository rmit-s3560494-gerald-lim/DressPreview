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
    // Tapping on picture will ask for camera or photo library
    
    let settings = UserSettings()
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!

    // UIPickerView is not shown in storyboard as it needs to be hidden by default
    let genderPicker = UIPickerView()
    let sizePicker = UIPickerView()
    
    // User saved preferences
    var genderSelected: String {
        return UserDefaults.standard.string(forKey: "genderSelected") ?? "N/A"
    }
    var sizeSelected: String {
        return UserDefaults.standard.string(forKey: "sizeSelected") ?? "N/A"
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
            saveImage(imageName: "profilepic.png")
        }
        else {
            // Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImage(imageName: "profilepic.png")
        genderTextField.text = genderSelected
        sizeTextField.text = sizeSelected
        genderTextField.inputView = genderPicker
        sizeTextField.inputView = sizePicker
        genderPicker.delegate = self
        sizePicker.delegate = self
        print(settings.genders)
        
        if let genderRow = settings.genders.index(of: genderSelected) {
            genderPicker.selectRow(genderRow, inComponent: 0, animated: false)
        }

        if let sizeRow = settings.sizes.index(of: sizeSelected) {
            sizePicker.selectRow(sizeRow, inComponent: 0, animated: false)
        }

    }
    
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
    
    func saveImage(imageName: String) {
        let fileManager = FileManager.default
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        
        let image = myImageView.image!
        
        let data = UIImagePNGRepresentation(image)
        
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    
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
