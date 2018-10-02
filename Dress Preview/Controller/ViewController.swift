//
//  ViewController.swift
//  Dress Preview
//
//  Created by Gerald Lim on 13/8/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import UIKit
import Disk
import Reachability

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerPreviewingDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (clothes?.itemSummaries?.count) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! CollectionViewCell
        if clothes != nil && clothes?.itemSummaries != nil {
            let cloth = clothes?.itemSummaries?[indexPath.row]
            if cloth != nil && cloth?.uimage != nil {
                cell.displayContent(image: (cloth?.uimage)!, title: cloth?.title ?? "default value")
            }
        }
        return cell
    }
    
    // Passing selected cell struct to DetailsViewController as viewCont
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Register collectionView for force touching
        let viewCont = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
        viewCont?.item = (clothes?.itemSummaries?[indexPath.row])!
        self.navigationController?.pushViewController(viewCont!, animated: false)
    }
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var viewCollection: UICollectionView!
    let reachability = Reachability()!
    
    var clothes: Cloth? = nil
    var apiClient = EBAYAPIClient(token: "Bearer <no token>")
    var cat = "15687"
    
    @IBAction func SegmentedSwitched(_ sender: Any) {
        if (self.cat == "15687"){
            cat = "185075"
            let q = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (!(q?.isEmpty)!)
            {
                apiSearch(apiClient, q: q!, limit: "10")
            }
            else {
                apiSearch(apiClient, q: "adidas", limit: "10")
            }
        }
        else {
            cat = "15687"
            let q = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (!(q?.isEmpty)!)
            {
                apiSearch(apiClient, q: q!, limit: "10")
            }
            else {
                apiSearch(apiClient, q: "adidas", limit: "10")
            }
        }
    }
    
    fileprivate func apiSearch(_ apiClient: EBAYAPIClient, q: String, limit: String) {
        // A simple request with no parameters
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        if reachability.connection != .none {
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
                    if er != nil && er?.first != nil && er?.first?.longMessage != nil {
                        print("\(String(describing: er?.first?.longMessage))")
                    }
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
                if !self.loadingIndicator.isHidden {
                    self.loadingIndicator.stopAnimating()
                }
            }
            print("Network not reachable")
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // First, get the index path and view for the previewed cell.
        guard let indexPath = viewCollection?.indexPathForItem(at: location) else { return nil }
        guard let cell = viewCollection?.cellForItem(at: indexPath) else { return nil }
        
        // Controller that the 3DTouch is peeking into
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else { return nil }
        
        let item = clothes?.itemSummaries?[indexPath.row]
        detailVC.item = item
        
        // Set 3DTouch content size
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 300)
        
        // Enable blurring of other UI elements, and a zoom in animation while peeking.
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Controller for final pop
        let finalView = viewControllerToCommit as! DetailsViewController
        show(finalView, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewCollection.isSpringLoaded = true
        
        if( traitCollection.forceTouchCapability == .available){
            
            registerForPreviewing(with: self, sourceView: view)
            
        }
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Connected to wifi")
            } else {
                print("Connected to cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
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
        if !self.apiClient.isTokenValid() {
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

    // Don't show navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Show navigation bar upon leaving view
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
}

//MARK: search bar
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        let q = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!(q?.isEmpty)!)
        {
            apiSearch(apiClient, q: searchBar.text!, limit: "10")
        }
        searchBar.showsCancelButton = false
        searchBar.text = text
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
