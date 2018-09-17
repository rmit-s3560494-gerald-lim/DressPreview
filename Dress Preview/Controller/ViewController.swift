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
        
        
        let apiClient = EBAYAPIClient(token: "Bearer <v^1.1#i^1#f^0#r^0#I^3#p^1#t^H4sIAAAAAAAAAOVXa2wUVRTu9oUVUBMRsUBcBkmqMjN3HvuasKvbLqU1C7tlCxEahTszd8rI7Mxm7mzbDYhNUTQFwg/DDxLQRowpVCqaoAKakCBq4o/+IGl8EXygQgKIMUYjiXpndynbSngWIXH/bO655557vu985965oLu65pENTRt+n+yZUN7XDbrLPR5uIqiprnr0rory2qoyUOLg6et+qLuyp+LkPAzTRkZajHDGMjHydqUNE0t5Y5jK2qZkQaxjyYRphCVHkVLRhXGJZ4CUsS3HUiyD8jbHwhREMAh4ny8IES+G/BqxmhditlphKsD7eNmvcioHQlAWfWQe4yxqNrEDTSdM8YAL0iBEc4FWACSBk3xBhg9yyynvUmRj3TKJCwOoSD5dKb/WLsn18qlCjJHtkCBUpDnamEpEm2PzF7XOY0tiRYo8pBzoZPHoUYOlIu9SaGTR5bfBeW8plVUUhDHFRgo7jA4qRS8kcx3pF6nmRRnKvCigQEAQ4bhQ2WjZaehcPg/Xoqu0lneVkOnoTu5KjBI25GeQ4hRHi0iI5pjX/WvJQkPXdGSHqfn10WXRZJKKPIGguQDKNh2zCYNJG9HJxTEaINUXkjU1SPuBCkKaEChuVIhWpHnMTg2Wqeouadi7yHLqEckajeWGL+GGOCXMhB3VHDejUj/+AocBcblb1EIVs84q060rShMivPnhlSswstpxbF3OOmgkwtiJPEWk1pmMrlJjJ/NaLMqnC4epVY6TkVi2s7OT6RQYy25neQA49smF8ZSyCqWJQrrSbq8X/PUrL6D1PBQFkZVYl5xchuTSRbRKEjDbqQgfCgBBKPI+Oq3IWOu/DCWY2dEdMV4dEuAEUYF+pAU0RfGFuPHokEhRpKybB5Jhjk5DezVyMgZUEK0QnWXTyNZVSfBpvBDUEK36QxothjSNln2qn+Y0hABCsqyEgv+nRrlaqacUK4OSlqEruXER/LiJXbDVJLSdXAoZBjFcreovCRK7IG86PLfXrwmiGwOTIDCjM662GcVKsxYkh5prWpHP+oZw6+Q+vK2KSgAWkOpq4SJj8nAZ3KEwpKWsrE3ucCbhnuut1mpkki5xbMswkL2UuyEmxu9Ev0Wn+SVRKYZOaFxxuyG7xmPyOrUNnVuIurLH03YJ5JxPCHCiKHDBG8LWkK9ra+4/OLSuqbBNFnaQehM+QNjRz6FIWf7H9Xj2gR7P2+RFBVgwh5sNZlVXLKmsmFSLdQcxOtQYrLeb5CvfRsxqlMtA3S6v9rTN2LtrRckDrO8pMG3kCVZTwU0seY+BGRdnqri775/MBUGICwAgcL7gcjD74mwlN7VySjt8ZduPvm+WVPTv/zVzz4KVU/ce3ggmjzh5PFVlRBlldQeq+tfUvrlOX98xPAuf6gWNTaenxnbF+99K4sSR1/d8/+2ur2d+5p116OVDjX9P651xPh0we9qOnRYeVl8anPMba9ZsEueen3D8XAv70fGJwx+8rxrDbxx7cDpuO7BTTMze2vvnwQkzTwxtG/xl/dYPF4TnNs0/netY++nxx+TO+ucGmSM7zqwZjJ+996w11Lsn+dXO/jXsD0+/Zyz7CbQc+C5x9K+B3e9UPtBe+/O89XXDJ6ZsvO8OLr3vXfbZoY7Pt9Sd64pEsx8PfDF93e6jB+s3e6XY2ZPV4R37X0ykZg68UPdJ9/Q7T8Vf690eP3hiaOOr+vMNscdbt2/2f3lmcKX4x6Tsph19a+OHC+X7B4cjt/EaDwAA>")

        
        // A simple request with no parameters
        apiClient.search(q: "adidas") {
            (clothes) in
            print("inside of in \(clothes.itemSummaries?.count)")
            DispatchQueue.main.async {
                self.clothes = clothes
                print("inside of GCD \(clothes.itemSummaries?.count)")
                self.viewCollection.reloadData()
            }
        }
    }
}

