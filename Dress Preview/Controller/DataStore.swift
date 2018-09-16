//
//  DataStore.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 13/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit

final class DataStore {
    
    static let sharedInstance = DataStore()
    fileprivate init () {}
    
    var cloth: [Cloth] = []
    var images: [UIImage] = []
    
    func getCloth(completion: @escaping () -> Void) {
        
        APIClient.getClothApi { (json) in
            let feed = json?["feed"] as? ClothJSON
            if let results = feed?["results"] as? [ClothJSON] {
                for dict in results{
                    let newCloth = Cloth(dictionary: dict)
                    self.cloth.append(newCloth)
                }
                completion()
            }
        }
    }
    
    func getBookImages(completion: @escaping () -> Void) {
        getCloth {
            for cloth in self.cloth {
                let url = URL(string: cloth.image)
                let data = try? Data(contentsOf: url!)
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    self.images.append(image!)
                }
            }
            OperationQueue.main.addOperation {
                completion()
            }
        }
    }
}
