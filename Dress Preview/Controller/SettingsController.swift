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
    
    // Arrays for gender and size choosing
    let genders = ["", "Male", "Female"]
    let sizes = ["", "XS", "S", "M", "L", "XL", "XXL", "XXXL"]
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!

    // UIPickerView is not shown in storyboard as it needs to be hidden by default
    let genderPicker = UIPickerView()
    let sizePicker = UIPickerView()
    
    // User saved preferences
    var genderSelected: String {
        return UserDefaults.standard.string(forKey: "genderSelected") ?? ""
    }
    var sizeSelected: String {
        return UserDefaults.standard.string(forKey: "sizeSelected") ?? ""
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
        
        if let genderRow = genders.index(of: genderSelected) {
            genderPicker.selectRow(genderRow, inComponent: 0, animated: false)
        }

        if let sizeRow = sizes.index(of: sizeSelected) {
            sizePicker.selectRow(sizeRow, inComponent: 0, animated: false)
        }

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == genderPicker) {
            return genders.count
        }
        else {
            return sizes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == genderPicker) {
            genderTextField.text = genders[row]
            UserDefaults.standard.set(genders[row], forKey: "genderSelected")
        }
        else {
            sizeTextField.text = sizes[row]
            UserDefaults.standard.set(sizes[row], forKey: "sizeSelected")
        }
        
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == genderPicker) {
            return genders[row]
        }
        else {
            return sizes[row]
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
