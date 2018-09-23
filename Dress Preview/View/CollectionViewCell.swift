//
//  CollectionViewCell.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 11/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
        
    @IBOutlet var clothImage: UIImageView!
    @IBOutlet var clothLabel: UILabel!
    
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemLabel: UILabel!
    
    func displayContent(image: UIImage, title: String/*, desc: String*/){
        clothImage.image = image
        clothLabel.text = title
        //clothDescription.text = desc
    }
    
    func displayItem(image: UIImage, title: String) {
        itemImage.image = image
        itemLabel.text = title
    }
}

class PreviewCell: UICollectionViewCell {
    @IBOutlet var im: UIImageView!
    
    func displayContent(image: UIImage) {
       self.im.image = image
    }
}
