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
import Reachability
import Disk

class PreviewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate {
    var receivedItemsTops = [Item]();
    var receivedItemsBots = [Item]();
    
    let reachability = Reachability()!
    var apiClient = EBAYAPIClient(token: "Bearer <no token>")
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of items :\(receivedItemsTops.count)")
        if collectionView == TopCollection {
            return receivedItemsTops.count
        }
        else {
            return receivedItemsBots.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == TopCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCell", for: indexPath) as! PreviewCellTop
            if receivedItemsTops[indexPath.row].uimage != nil {
                cell.displayContent(image: receivedItemsTops[indexPath.row].uimage!)
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BotCell", for: indexPath) as! PreviewCellBot
            if receivedItemsBots[indexPath.row].uimage != nil {
                cell.displayContent(image: receivedItemsBots[indexPath.row].uimage!)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == TopCollection {
            topPreview.image = receivedItemsTops[indexPath.row].uimage
            if !UIApplication.shared.statusBarOrientation.isLandscape {
                TopCollection.isHidden = true
            }
        }
        else {
            botPreview.image = receivedItemsBots[indexPath.row].uimage
            if !UIApplication.shared.statusBarOrientation.isLandscape {
                BotCollection.isHidden = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TopCollection.dataSource = self
        TopCollection.delegate = self
        BotCollection.delegate = self
        BotCollection.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        let token = try? Disk.retrieve("OauthToken.json", from: .caches, as: OauthResponse.self)
        if token != nil {
            self.apiClient.oauthToken = "Bearer <\(token!.accessToken))>"
        }
        let tapGestureTop = UITapGestureRecognizer(target: self, action: #selector(PreviewController.imageTappedTop(gesture:)))
        let tapGestureBot = UITapGestureRecognizer(target: self, action: #selector(PreviewController.imageTappedBot(gesture:)))
        // add it to the image view;
        topPreview.addGestureRecognizer(tapGestureTop)
        botPreview.addGestureRecognizer(tapGestureBot)
        // make sure imageView can be interacted with by user
        botPreview.isUserInteractionEnabled = true
        topPreview.isUserInteractionEnabled = true
        if !UIApplication.shared.statusBarOrientation.isLandscape {
            TopCollection.isHidden = true
            BotCollection.isHidden = true
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            if UIApplication.shared.statusBarOrientation.isLandscape {
                // activate landscape changes
                if self.TopCollection != nil && self.BotCollection != nil {
                    self.TopCollection.isHidden = false
                    self.BotCollection.isHidden = false
                }
            } else {
                // activate portrait changes
                if self.TopCollection != nil && self.BotCollection != nil {
                    self.TopCollection.isHidden = true
                    self.BotCollection.isHidden = true
                }
            }
        })
    }
    
    @IBOutlet var topPreview: UIImageView!
    @IBOutlet var TopCollection: UICollectionView!
    @IBOutlet var BotCollection: UICollectionView!
    @IBOutlet var botPreview: UIImageView!
    
    fileprivate func apiSearch(_ apiClient: EBAYAPIClient, q: String, selector: Bool, ind: Bool) {
        if reachability.connection != .none {
            apiClient.searchItem(q: q) { response in
                switch response {
                case .success(let item as Item):
                    //TopCollection is clicked
                    if selector {
                        //item is a top
                        if item.categoryID == "15687" {
                            //add item to collection
                            if !self.receivedItemsTops.contains(where: {$0.itemID == item.itemID}) {
                                self.receivedItemsTops.append(item)
                                //reload collection
                                DispatchQueue.main.async {
                                    self.TopCollection.reloadSections(IndexSet(integer: 0))
                                }
                            }
                        }
                    }
                        //BotCollection is clicked
                    else {
                        //item is a bot
                        if item.categoryID == "185075" {
                            //add item to collection
                            if !self.receivedItemsBots.contains(where: {$0.itemID == item.itemID}) {
                                self.receivedItemsBots.append(item)
                                //reload collection
                                DispatchQueue.main.async {
                                    self.BotCollection.reloadSections(IndexSet(integer: 0))
                                }
                            }
                        }
                    }
                case .failure(let error as APIErrors):
                    let er = error.errors
                    if er != nil && er?.first != nil && er?.first?.longMessage != nil {
                        print("\(String(describing: er?.first?.longMessage))")
                    }
                    print("try to get a new token")
                    print(apiClient.isTokenValid())
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
            print("Completed search for one item")
        }
    }
    
    @objc func imageTappedBot(gesture: UIGestureRecognizer) {
        if !UIApplication.shared.statusBarOrientation.isLandscape {
            if (gesture.view as? UIImageView) != nil {
                print("image bot tapped")
                fetchFavSearch(sel: false)
            }
        }
    }
    
    fileprivate func fetchFavSearch(sel:Bool) {
        //Here you can initiate your new ViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                if sel {
                    TopCollection.isHidden = false
                }
                else {
                    BotCollection.isHidden = false
                }
            }
            else {
                let alert = UIAlertController(title: "Information", message: "No favourites, add favourites from browse page", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            var index = 0
            var last = false
            for data in result as! [NSManagedObject] {
                let str = data.value(forKey: "favourites") as! String
                index = index + 1
                if index == result.count {
                    last = true
                }
                if !self.apiClient.isTokenValid() {
                    try? apiClient.refreshToken() { response in
                        switch response {
                        case .success( _ as OauthResponse):
                            print("Token refreshed successfully")
                            self.apiSearch(self.apiClient, q: str, selector: sel, ind: last)
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
                    self.apiSearch(self.apiClient, q: str, selector: sel, ind: last)
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    @objc func imageTappedTop(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if !UIApplication.shared.statusBarOrientation.isLandscape {
            if (gesture.view as? UIImageView) != nil {
                print("Image top Tapped")
                fetchFavSearch(sel: true)
            }
        }
    }
}
