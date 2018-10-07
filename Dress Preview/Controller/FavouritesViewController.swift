//
//  FavouritesViewController.swift
//  Dress Preview
//
//  Created by Kunga Kartung on 22/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import UIKit
import Disk
import Reachability
import CoreData

class FavouritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let test = Favourites()
    
    var item: Item? = nil
    var receivedItems = [Item]()
    
    let reachability = Reachability()!
    var apiClient = EBAYAPIClient(token: "Bearer <no token>")
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var viewCollection: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return (receivedItems.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! CollectionViewCell

        if(!receivedItems.isEmpty) {
            let displayedItem = receivedItems[indexPath.row]
            if displayedItem.uimage != nil {
                cell.displayItem(image: (displayedItem.uimage)!, title: displayedItem.title ?? "default value")
                cell.delegate = self
            }
        }
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if let indexPaths = viewCollection?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = viewCollection?.cellForItem(at: indexPath) as? CollectionViewCell {
                    cell.isEditing = editing
                }
            }
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: "No internet connection, please verify your connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            print("Network not reachable")
        }
    }
    
    fileprivate func apiSearch(_ apiClient: EBAYAPIClient, q: String) {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        if reachability.connection != .none {
            apiClient.searchItem(q: q) { response in
                switch response {
                case .success(let dataContainer as Item):
                    if !self.receivedItems.contains(where: {$0.itemID == dataContainer.itemID}) {
                        self.receivedItems.append(dataContainer)
                    }
                    DispatchQueue.main.async {
                        self.viewCollection.reloadSections(IndexSet(integer: 0))
                        self.loadingIndicator.stopAnimating()
                    }
                case .failure(let error as APIErrors):
                    let er = error.errors
                    if er != nil && er?.first != nil && er?.first?.longMessage != nil {
                        print("\(String(describing: er?.first?.longMessage))")
                    }
                    print("try to get a new token")
                    print(apiClient.isTokenValid())
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true;
                    }
                case .success(_): break
                    
                case .failure(let res as String):
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: res, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.loadingIndicator.stopAnimating()
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    fileprivate func CoreDataSearch() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            // pull each data out of favourites attrib and search for that item
            for data in result as! [NSManagedObject] {
                let str = data.value(forKey: "favourites") as! String
                self.apiSearch(self.apiClient, q: str)
            }
        }
        catch {
            print("Failed")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
//        FavouritesViewController.reloadData()
        
        print("testing import")
        print(test.imageNames.count)
        
        do{
            let results = try context.fetch(request)
            for result in results as! [NSManagedObject]
            {
                let resultString = result.value(forKey: "favourites") as! String
                
                if !receivedItems.contains(where: {$0.itemID == resultString}) {
                    self.apiSearch(self.apiClient, q: resultString)
                }
            }
            try context.save()
        } catch {
            print("Failed")
        }
        
        DispatchQueue.main.async {
            self.viewCollection.reloadData();
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.rightBarButtonItem = self.editButtonItem
        
        self.loadingIndicator.stopAnimating()
        
        // Check connection to internet through wifi or 4g otherwise print error
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Connected to wifi")
            } else {
                print("Connected to cellular")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        // Pull the token out of .cache folder on phone and verify
        let token = try? Disk.retrieve("OauthToken.json", from: .caches, as: OauthResponse.self)
        if token != nil {
            self.apiClient.oauthToken = "Bearer <\(token!.accessToken))>"
        }
        if !self.apiClient.isTokenValid() {
            try? apiClient.refreshToken() { response in
                switch response {
                case .success( _ as OauthResponse):
                    print("Token refreshed successfully")
                    self.CoreDataSearch()
                case .failure( _ as OauthError):
                    print("Token failed to refresh")
                case .success(_):
                    break
                case .failure(_):
                    break
                }
            }
        }
        else {
            CoreDataSearch()
        }
    }
}
extension FavouritesViewController : ViewCellDelegate {
    func delete(cell: CollectionViewCell) {
        if let indexPath = viewCollection?.indexPath(for: cell) {
            // Delete from data source
            let toRemove = receivedItems[indexPath.row].itemID
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let myRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            myRequest.predicate = NSPredicate(format: "favourites = %@", toRemove!)
            do{
                let results = try context.fetch(myRequest)
                for result in results
                {
                    context.delete(result as! NSManagedObject)
                }
                try context.save()
                receivedItems.remove(at: indexPath.row)
            } catch let error{
                print(error)
            }
            // Delete from view collection
            viewCollection?.deleteItems(at: [indexPath])
        }
    }
}
