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
    func displayContent(image: UIImage, title: String/*, desc: String*/){
        clothImage.image = image
        clothLabel.text = title
        //clothDescription.text = desc
    }
}
