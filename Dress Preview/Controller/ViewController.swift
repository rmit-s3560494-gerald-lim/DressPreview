//
//  ViewController.swift
//  Dress Preview
//
//  Created by Gerald Lim on 13/8/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import UIKit
import Disk

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (clothes?.itemSummaries?.count) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! CollectionViewCell
        let cloth = clothes?.itemSummaries?[indexPath.row]
        //let url = URL(cloth?.image?.imageURL)
        
//        let image = try? UIImage.init(withContentsOfUrl: url)!
        cell.displayContent(image: (cloth?.uimage)!, title: cloth?.title ?? "default value")
        return cell
    }
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var viewCollection: UICollectionView!

    var clothes: Cloth? = nil
    var apiClient = EBAYAPIClient(token: "Bearer <no token>")
    var cat = "15687"
    
    @IBAction func SegmentedSwitched(_ sender: Any) {
        if (self.cat == "15687"){
            cat = "185075"
        }
        else {
            cat = "15687"
        }
    }
    fileprivate func apiSearch(_ apiClient: EBAYAPIClient, q: String, limit: String) {
        //        if (apiClient.oauthToken == "Bearer <no token>"){
        //            try? apiClient.getNewToken()
        //        }
        
        // A simple request with no parameters
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        apiClient.search(q: q, category: cat, limit: "10") { response in
            switch response {
            case .success(let dataContainer as Cloth):
                self.clothes = dataContainer
                DispatchQueue.main.async {
                    self.viewCollection.reloadSections(IndexSet(integer: 0))
                    self.loadingIndicator.stopAnimating()
                }
            case .failure(let error as APIErrors):
                let er = error.errors
                print("\(String(describing: er?.first?.longMessage!))")
                print("try to get a new token")
                print(apiClient.isTokenValid())
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = try? Disk.retrieve("OauthToken.json", from: .caches, as: OauthResponse.self)
        if (token != nil) {
            self.apiClient.oauthToken = "Bearer <\(token!.accessToken))>"
        }
        if (!self.apiClient.isTokenValid()) {
            try? apiClient.refreshToken() { response in
                switch response {
                case .success( _ as OauthResponse):
                    print("Token refreshed successfully")
                    self.apiSearch(self.apiClient, q: "adidas",limit: "10")
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
            self.apiSearch(self.apiClient, q: "adidas", limit: "10")
        }
    }
}

//MARK: search bar
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let q = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!(q?.isEmpty)!)
        {
            apiSearch(apiClient, q: searchBar.text!, limit: "10")
        }
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

//MARK: loading images
extension UIImage {
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
    
}

//MARK: loading spinner
extension UIViewController {

}
