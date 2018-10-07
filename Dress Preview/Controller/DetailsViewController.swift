//
//  DetailsViewController.swiftDetailsViewController
//  Dress Preview
//
//  Created by Kunga Kartung on 17/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var ebayBuy: UIImageView!
    
    var item: ItemSummary? = nil
    var favItem: Item? = nil
    var trackingID: String = ""
    var isInFav = false
    var isHidden = false
    
    // Action for tapping on Ebay Buy Image
    @IBAction func ebayBuyTap(_ sender: Any) {
        if(!(item == nil)) {
            UIApplication.shared.open(URL(string: (item?.itemWebURL)!)!)
        } else {
            UIApplication.shared.open(URL(string: (favItem?.itemWebURL)!)!)
        }
    }

    override func viewDidLoad() {
        // Favourite button hiding switch
        if isHidden {
            favButton.isHidden = true
        }
        
        // Switch to see which controller accessed this scene
        // item set from viewcontroller
        // favItem set from favouritesviewcontroller
        if(!(item == nil)) {
            mainTitle.text = item?.title
            mainImage.image = item?.uimage
            price.text = "$" + (item?.price?.value)!
            trackingID = item?.itemID ?? ""
        } else {
            mainTitle.text = favItem?.title
            mainImage.image = favItem?.uimage
            price.text = "$" + (favItem?.price?.value)!
            trackingID = favItem?.itemID ?? ""
        }
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if(data.value(forKey: "favourites") as! String == trackingID) {
                    favButton.setTitle("Remove from Favourites", for: .normal)
                    isInFav = true
                } else {
                    favButton.setTitle("Add to Favourites", for: .normal)
                    isInFav = false
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    // Force touch actions defined here
    override var previewActionItems: [UIPreviewActionItem] {
        
        let favouriteAction = UIPreviewAction(title: "Add to Favourites", style: .default) { (action: UIPreviewAction, DetailsViewController) -> Void in
            // Add to favourites functionality
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
            let currUser = NSManagedObject(entity: entity!, insertInto: context)
            currUser.setValue(self.item?.itemID, forKey: "favourites")
            do {
                try context.save()
                print("success add to fav switch")
                self.favButton.setTitle("Remove from Favourites", for: .normal)
                self.isInFav = true
            } catch {
                print("Failed saving")
            }
        }
        return [favouriteAction]
        
    }
    
    // Add to core data if user clicks Add to Favourites which is displayed when itemID is not in coredata
    // else it will display remove from favourites meaning that the itemID is already in coredata thus user
    // can choose to remove it form their favourites therefore from coredata
    // Update button text in response to user actions.
    @IBAction func addToFavTapped(_ sender: Any) {
        if(isInFav == false) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
            let currUser = NSManagedObject(entity: entity!, insertInto: context)
            currUser.setValue(item?.itemID, forKey: "favourites")
            do {
                try context.save()
                print("success add to fav switch")
                favButton.setTitle("Remove from Favourites", for: .normal)
                isInFav = true
            } catch {
                print("Failed saving")
            }
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let myRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            myRequest.predicate = NSPredicate(format: "favourites = %@", trackingID)
            do{
                let results = try context.fetch(myRequest)
                for result in results
                {
                    context.delete(result as! NSManagedObject)
                    print("success deleted from fav switch")
                    favButton.setTitle("Add to Favourites", for: .normal)
                    isInFav = false;
                }
                try context.save()
            } catch let error{
                print(error)
            }
        }
    }
}
