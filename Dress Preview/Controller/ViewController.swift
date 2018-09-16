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
        
        
        let apiClient = EBAYAPIClient(token: "Bearer <v^1.1#i^1#p^1#f^0#I^3#r^0#t^H4sIAAAAAAAAAOVXa2wUVRTubB9aoaVEVIJg1qlGIpnZOzvd2ZmRXbO0UJZXV7a8irWZx512ZHZmnblLWRFSyytpQIhGHj5SMEFEjQGURBMfkWAMWusPYwwhkQhIeAhK+MEPCXhndinbSngWIXH/bO655577fd855965oKOs/MmVk1eeqyDu8W3uAB0+gmCGgPKy0nGVxb5RpUWgwIHY3PFYR0ln8bHxjpQy0uJM6KQt04H+RSnDdETPGCEztilakqM7oimloCMiRUzGpk8TgzQQ07aFLMUySH+8LkKyvKoxvCCoYYGXOVnAVvNSzEYrQspMqCbI8xIblIOwRmPwvONkYNx0kGSiCBkEDE8BgWK4RqZGZDkRcDQXFppI/2xoO7plYhcakFEPruittQuwXh2q5DjQRjgIGY3HJiUbYvG6iTMaxwcKYkXzOiSRhDJO/1GtpUL/bMnIwKtv43jeYjKjKNBxyEA0t0P/oGLsEpibgO9JDWWBlSVW0sKhIM/x/KBIOcmyUxK6Og7XoquU5rmK0EQ6yl5LUayG/DxUUH40A4eI1/ndv2cykqFrOrQj5MQJsXmxRIKMToGSWS/JNlVnYwUTNqQSM+soANWQIGsqT3FABYLGhvMb5aLlZR6wU61lqrormuOfYaEJEKOGA7UJFmiDnRrMBjumIRdRoR/XpyHT5CY1l8UMajPdvMIUFsLvDa+dgb7VCNm6nEGwL8LACU+iCCml07pKDpz0ajFfPoucCNmGUFoMBNrb2+l2lrbs1kAQACYwd/q0pNIGUxKJfd1ez/nr115A6R4VBeKVji6ibBpjWYRrFQMwW8loUAgDls3r3h9WdKD1X4YCzoH+HTFYHRKECgyHBD4EaiBQlPBgdEg0X6QBFweUpSyVkuwFEKUNSYGUgussk4K2ropsSAuyvAYplRM0qkbQNEoOqRzFaBACCGVZEfj/U6Ncb6knFSsNE5ahK9lBKfhBK3bWVhOSjbJJaBjYcL1Vf0WSjkvyttNze/2GKLoxHBxESuu0W9u0YqUCloQPNdfU4qG+Jd46vg/vqqRigjmmupq7yGiPLu0sVGjcUlbGxnc43eCe643WAmjiLkG2ZRjQns3ckhKDd6LfodP8iqwUQ8cyttxtzG7wmLzJ2pbQHWRd0knMvwJzJsSGGcCHOO6WuNV6eW3M/geH1g0ldrLlIKjehg+QQP/nULTI+zGdxG7QSezELyoQAI8z1eDRsuJZJcVDRzk6grQuabSjt5r4K9+G9AKYTUu67Ssj5o/esb2l4AG2uRmM7HuClRczQwreY2D05ZlSZthDFQwPBIZjalgOcE2g+vJsCfNgyYh9y7p7jTlT3qwaTizr8f3+VPezc+Kgos+JIEqLcGUU7d62oqp9kwpmfbb446oz21YdrKzclTjRtbDr0eITW5otNdb54ZLVbe/+8vaq4z/6jwbm9px64f4t79W/eME388jaoUNOPvD5XvPo4cUv/XBg/zj+4Dc7w8z3YzdOP3CGmLp06cVR5/9+5eGpc8beew4+MbGr6gKxt/T13mE7fSdf3VPfHI32/vFB6/D1X8fJPUvOVj3deua7Y/VJ/nRzufJF9ZiynsPVG77d8Gd0xLGX31m9dd7IvyY1rfhVHPfa+y1THmka89b20uPcmn27umu75n0ZX76+7ei6dfsSmepzp/1faVPXrC35ecSOinWfHuF/6mk/VLX8/NmPtlb+dnFjNFWx49AbvWX3fbLpVPeB/Y3PDc2l7x8G6S51Gg8AAA==>")

        
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

