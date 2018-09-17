//
//  ViewController.swift
//  Dress Preview
//
//  Created by Gerald Lim on 13/8/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (clothes?.itemSummaries?.count) ?? 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! CollectionViewCell
        let cloth = clothes?.itemSummaries?[indexPath.row]
        cell.displayContent(title: cloth?.title ?? "default value")
        return cell
    }
    
    @IBOutlet var viewCollection: UICollectionView!

    var clothes: Cloth? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let apiClient = EBAYAPIClient(token: "Bearer <v^1.1#i^1#r^0#p^1#f^0#I^3#t^H4sIAAAAAAAAAOVXW2wUVRjutttWUkq1qVKh6jqAUXBmz+x0d3Yn7ei220KVXujWRlpJc3bmTDtldmacOUu7MZKmBLyQNDFgRMTYxoBVRGsU4wNJMUbihYSYaISGxAe0IU141USUeGZ2KdtKuBYhcV8285///Of7vv8yc8BQ0aLVO9bt+KPUU5w/OgSG8j0etgQsKipcs6Qgf1lhHshx8IwOrRzyDhecrbFhUjOFdmSbhm4j32BS023BNdZSKUsXDGirtqDDJLIFLAnxaPN6IcAAwbQMbEiGRvmaYrVUIMCFE0EuIAVYVC2hamLVL8bsMGqpak6SeLISglJ1ROERWbftFGrSbQx1TPYDNkyDCM3yHSAkBIAAgkw4wHVRvk5k2aqhExcGUKILV3D3WjlYrwwV2jayMAlCiU3RxnhrtCnW0NJR48+JJWZ1iGOIU/bcp3pDRr5OqKXQlY+xXW8hnpIkZNuUX8ycMDeoEL0I5gbgu1IrYQmGIS+zMIRklmcXRMpGw0pCfGUcjkWVacV1FZCOVZy+mqJEjUQ/knD2qYWEaIr5nL8NKaipioqsWqqhLrox2tZGiU8hqK+FCYuOWUTBNgvRbe0xGiA5GEkocpgOARlEFI7PHpSJlpV53kn1hi6rjmi2r8XAdYigRvO1YXO0IU6teqsVVbCDKNcvfFFDNtTlJDWTxRTu0528oiQRwuc+Xj0Ds7sxttRECqPZCPMXXIlqKWiaqkzNX3RrMVs+g3Yt1YexKfj9AwMDzADHGFavPwAA63+2eX1c6kNJSBFfp9cz/urVN9CqS0UibUr8BZw2CZZBUqsEgN5LiYEIDzguq/tcWOJ8678MOZz9cztioToEhSKhcDWvQC4Y4SIBuBAdImaL1O/gQAmYppPQ2oywqUEJ0RKps1QSWaoscEGFzEIF0XIootBk2Cl0IiiHaFZBCCCUSEiR8P+pUa611OOSYaI2Q1Ol9IIU/IIVO2fJbdDC6TjSNGK41qq/LEnbIXnL6Tm9fl0UnRg2CQJNlXFqm5GMpN+AZKg5ph4X9U3xVsn78I5KKiGYYarKmRcZ49Jl7C0SQ1rKSFnkHc60OnO9w9iMdNIl2DI0DVmd7E0psXAT/TZN88uykjSVyNhzpzG7zjF5g7UN8W1k7R32dF+GORvkeDYUDIDgTXGrd/Pakf4PhtZ1JXadYWMk34IPEP/c65CY5/7YYc9hMOz5hNyogB+sYleAh4sKnvEWLF5mqxgxKlQYW+3VyVe+hZjNKG1C1cov8nRXTbzfk3MBG90EKmevYIsK2JKc+xiourRSyJYtLWXDIMLyIESECXaBFZdWvex93ooHqlqWjU7tfnIx31JyIfb48ed3froHlM46eTyFeaQy8sYnK8s/PLC8/+XJH5dWbD97pHe6cesrr+7r+ZXnGzf9dXpm5uhdk2+e2zd1cqL9/krtz/6vKXHJ3nRja93x5Sv6X9v/tG+ku7KhfNeJmo/PHxo588H0t6sqR7ZIXzYUD44tL377JW5Vz+/Fb4288DP1zrGyo/Vd0TNy98lmxluz5jS3WP6liNmTKN93Shz7omrsufHCY/vzDskbKo4dFN+bfpSVvekfzpz/bmyGpYab96bP4fzt29Yd/r71q3vij3R2lgyYZVNVpUNv3Bt/aPrEwIUy9Hrzg3db+ampSviYeOqn2Mnx+G9bt63edXDtN6MzvX3HA1sPaO+++PnGJ/4WJo7UfWTuXnlqyWczmfT9A+MMS2YaDwAA>")

        
        // A simple request with no parameters
        apiClient.search(q: "adidas", category: "15687", limit: "10") {
            (clothes) in
            print("inside of in \(clothes.itemSummaries?.count ?? -1)")
            DispatchQueue.main.async {
                self.clothes = clothes
                print("inside of GCD \(clothes.itemSummaries?.count ?? -1)")
                self.viewCollection.reloadData()
            }
        }
    }
}

