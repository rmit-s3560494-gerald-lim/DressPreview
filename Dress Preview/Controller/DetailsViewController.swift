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
    
    var item: ItemSummary? = nil
    var trackingID: String = ""
    var isInFav = false

    override func viewDidLoad() {
        mainTitle.text = item?.title
        mainImage.image = item?.uimage
        price.text = "$" + (item?.price?.value)!
        trackingID = item?.itemID ?? ""
        
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
    
    @IBAction func ebayBuyButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: (item?.itemWebURL)!)!)
    }
    
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
