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
    var item: Item? = nil
    var receivedItemsTops = [Item]();
    
    let reachability = Reachability()!
    var apiClient = EBAYAPIClient(token: "Bearer <no token>")
    
    let imageArray = ["1.jpeg","2.jpeg","3.jpeg","4.jpeg","5.jpeg"]
    let imageArrayTop = ["1top.jpeg","2top.jpeg","3top.jpeg","4top.jpeg","5top.jpeg"]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArrayTop.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == TopCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCell", for: indexPath) as! PreviewCellTop
            cell.displayContent(image: UIImage(named: imageArrayTop[indexPath.row])!)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BotCell", for: indexPath) as! PreviewCellBot
            cell.displayContent(image: UIImage(named: imageArray[indexPath.row])!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == TopCollection {
            topPreview.image = UIImage(named: imageArrayTop[indexPath.row])
            TopCollection.isHidden = true
        }
        else {
            botPreview.image = UIImage(named: imageArray[indexPath.row])
            BotCollection.isHidden = true
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
        TopCollection.isHidden = true
        BotCollection.isHidden = true
    }
    @IBOutlet var topPreview: UIImageView!
    @IBOutlet var TopCollection: UICollectionView!
    @IBOutlet var BotCollection: UICollectionView!
    @IBOutlet var botPreview: UIImageView!
    
    fileprivate func apiSearch(_ apiClient: EBAYAPIClient, q: String) {
        if reachability.connection != .none {
            apiClient.searchItem(q: q) { response in
                switch response {
                case .success(let dataContainer as Item):
                    self.item = dataContainer
                    if self.item?.categoryID == "15687" {
                        if !self.receivedItemsTops.contains(where: {$0.itemID == self.item?.itemID}) {
                            self.receivedItemsTops.append(self.item!)
                            DispatchQueue.main.async {
                                self.TopCollection.reloadSections(IndexSet(integer: 0))
                            }
                        }
                    }
                    else {
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
        if (gesture.view as? UIImageView) != nil {
            print("image bot tapped")
            fetchFavSearch(sel: false)
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
            for data in result as! [NSManagedObject] {
                let str = data.value(forKey: "favourites") as! String
                
                if !self.apiClient.isTokenValid() {
                    try? apiClient.refreshToken() { response in
                        switch response {
                        case .success( _ as OauthResponse):
                            print("Token refreshed successfully")
                            self.apiSearch(self.apiClient, q: str)
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
                    self.apiSearch(self.apiClient, q: str)
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    @objc func imageTappedTop(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            print("Image top Tapped")
            fetchFavSearch(sel: true)
        }
    }
}
