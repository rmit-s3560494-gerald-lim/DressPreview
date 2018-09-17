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
    let genders = [String](arrayLiteral: "", "Male", "Female")
    let sizes = [String](arrayLiteral: "", "XS", "S", "M", "L", "XL", "XXL", "XXXL")
    
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!

    // UIPickerView is not shown in storyboard as it needs to be hidden by default
    let genderPicker = UIPickerView()
    let sizePicker = UIPickerView()

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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImageView.image = image
        }
        else {
            // Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderTextField.inputView = genderPicker
        sizeTextField.inputView = sizePicker
        genderPicker.delegate = self
        sizePicker.delegate = self
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
        }
        else {
            sizeTextField.text = sizes[row]
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
    
}
