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
    
    var item: ItemSummary? = nil
    
    @NSManaged var favs: [String]
    
    
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "favourites") as! String)
            }
        } catch {
            print("Failed")
        }
        
        mainTitle.text = item?.title
        mainImage.image = item?.uimage
        price.text = item?.price?.value
    }
    
    @IBAction func ebayBuyButtonPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: (item?.itemWebURL)!)!)
    }
    
    @IBAction func addToFavTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
//
//        request.returnsObjectsAsFaults = false
//        do {
//
//            let result = try context.fetch(request)
//            if result.contains(where: {$0 == ite}) {
//
//            }
//        } catch {
//            print("Failed")
//        }
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let currUser = NSManagedObject(entity: entity!, insertInto: context)
        
        currUser.setValue(item?.title, forKey: "favourites")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("Failed saving")
        }
        
        
        
    }
}
