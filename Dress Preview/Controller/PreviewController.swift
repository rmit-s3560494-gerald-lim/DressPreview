//
//  PreviewController.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 23/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PreviewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCell", for: indexPath) as! PreviewCell
        return cell
    }
    
    override func viewDidLoad() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PreviewController.imageTapped(gesture:)))
        
        // add it to the image view;
        topPreview.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        topPreview.isUserInteractionEnabled = true
        TopCollection.isHidden = true
        BotCollection.isHidden = true
    }
    @IBOutlet var topPreview: UIImageView!
    @IBOutlet var TopCollection: UICollectionView!
    @IBOutlet var BotCollection: UICollectionView!
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            //Here you can initiate your new ViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                if result.count > 0 {
                    TopCollection.isHidden = false
                }
                for data in result as! [NSManagedObject] {
                    print(data.value(forKey: "favourites") as! String)
                }
            } catch {
                print("Failed")
            }
        }
    }
}
