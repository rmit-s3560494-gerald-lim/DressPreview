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

class FavouritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var item: Item? = nil
    var receivedItems = [Item]();
    
    let reachability = Reachability()!
    var apiClient = EBAYAPIClient(token: "Bearer <no token>")
    
    @IBOutlet var viewCollection: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return (receivedItems.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! CollectionViewCell

        if(!receivedItems.isEmpty) {
            print(indexPath.count)
            let displayedItem = receivedItems[indexPath.row]
            cell.displayItem(image: (displayedItem.uimage)!, title: displayedItem.title ?? "default value")
        }
        
        return cell
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
        if reachability.connection != .none {
            apiClient.searchItem(q: q) { response in
                switch response {
                case .success(let dataContainer as Item):
                    self.item = dataContainer
                    self.receivedItems.append(self.item!)
                    DispatchQueue.main.async {
                    self.viewCollection.reloadSections(IndexSet(integer: 0))
                    }
                case .failure(let error as APIErrors):
                    let er = error.errors
                    if er != nil && er?.first != nil && er?.first?.longMessage != nil {
                        print("\(String(describing: er?.first?.longMessage))")
                    }
                case .success(_): break
                    
                case .failure(let res as String):
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: res, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
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
        } catch {
            print("Failed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
