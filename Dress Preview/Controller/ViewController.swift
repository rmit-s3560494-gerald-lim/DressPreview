//
//  ViewController.swift
//  Dress Preview
//
//  Created by Gerald Lim on 13/8/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import UIKit
import Disk

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (clothes?.itemSummaries?.count) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! CollectionViewCell
        let cloth = clothes?.itemSummaries?[indexPath.row]
        //let url = URL(cloth?.image?.imageURL)
        guard let url = URL(string: (cloth?.image?.imageURL)!) else {
            return cell
        }
        let image = try? UIImage.init(withContentsOfUrl: url)!
        cell.displayContent(image: image!, title: cloth?.title ?? "default value")
        return cell
    }
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var viewCollection: UICollectionView!

    var clothes: Cloth? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = try? Disk.retrieve("OauthToken.json", from: .temporary, as: OauthResponse.self)
        let apiClient = EBAYAPIClient(token: "Bearer <\(token?.accessToken ?? "no token")>")

        
        // A simple request with no parameters
        apiClient.search(q: "adidas", category: "15687", limit: "10") { response in
            switch response {
            case .success(let dataContainer as Cloth):
                DispatchQueue.main.async {
                    self.clothes = dataContainer
                    self.viewCollection.reloadData()
                }
            case .failure(let error as APIErrors):
                let er = error.errors
                print("\(String(describing: er?.first?.longMessage!))")
                print("try get new token")
                try? apiClient.getNewToken()
            case .success(_): break
                
            case .failure(_): break
                
            }
        }
    }
}

extension UIImage {
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
    
}
