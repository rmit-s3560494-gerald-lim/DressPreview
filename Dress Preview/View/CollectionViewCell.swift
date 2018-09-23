//
//  CollectionViewCell.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 11/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit

protocol ViewCellDelegate: AnyObject {
    func delete(cell: CollectionViewCell)
}

class CollectionViewCell: UICollectionViewCell {
        
    @IBOutlet var clothImage: UIImageView!
    @IBOutlet var clothLabel: UILabel!
    
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemLabel: UILabel!
    
    @IBOutlet weak var deleteButtonBGView: UIVisualEffectView!
    
    weak var delegate: ViewCellDelegate?
    
    func displayContent(image: UIImage, title: String/*, desc: String*/){
        clothImage.image = image
        clothLabel.text = title
        //clothDescription.text = desc
    }
    
    func displayItem(image: UIImage, title: String) {
        itemImage.image = image
        itemLabel.text = title
        
        deleteButtonBGView.layer.cornerRadius = deleteButtonBGView.bounds.width / 2.0
        deleteButtonBGView.layer.masksToBounds = true
        deleteButtonBGView.isHidden = !isEditing
    }
    
    var isEditing: Bool = false {
        didSet {
            deleteButtonBGView.isHidden = !isEditing
        }
    }
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        delegate?.delete(cell: self)
    }
}

class PreviewCellTop: UICollectionViewCell {
    @IBOutlet var im: UIImageView!
    
    func displayContent(image: UIImage) {
       self.im.image = image
    }
}

class PreviewCellBot: UICollectionViewCell {
    @IBOutlet var im: UIImageView!
    
    func displayContent(image: UIImage) {
        self.im.image = image
    }
}
