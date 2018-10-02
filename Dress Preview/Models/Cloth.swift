//
//  Cloth.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 14/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit

struct Cloth: Codable {
    let href: String?
    let total: Int?
    let next: String?
    let limit, offset: Int?
    var itemSummaries: [ItemSummary]?
}

struct ItemSummary: Codable {
    let itemID, title: String?
    let itemGroupHref: String?
    let image: Image?
    let price: CurrentBidPrice?
    let itemGroupType: String?
    let itemHref: String?
    let seller: Seller?
    let marketingPrice: MarketingPrice?
    let condition, conditionID: String?
    let shippingOptions: [ShippingOption]?
    let buyingOptions: [String]?
    let currentBidPrice: CurrentBidPrice?
    let epid: String?
    let itemAffiliateWebURL, itemWebURL: String?
    let itemLocation: ItemLocation?
    let categories: [Category]?
    let adultOnly: Bool?
    let additionalImages: [Image]?
    var uimage: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case itemID = "itemId"
        case title, itemGroupHref, image, price, itemGroupType, itemHref, seller, marketingPrice, condition
        case conditionID = "conditionId"
        case shippingOptions, buyingOptions, currentBidPrice, epid
        case itemAffiliateWebURL = "itemAffiliateWebUrl"
        case itemWebURL = "itemWebUrl"
        case itemLocation, categories, adultOnly, additionalImages
    }
}

struct Image: Codable {
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "imageUrl"
    }
}

struct Category: Codable {
    let categoryID: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "categoryId"
    }
}

struct CurrentBidPrice: Codable {
    let value: String?
    let currency: Currency?
}

enum Currency: String, Codable {
    case usd = "USD"
}

struct ItemLocation: Codable {
    let postalCode, country: String?
}

struct MarketingPrice: Codable {
    let originalPrice: CurrentBidPrice?
    let discountPercentage: String?
    let discountAmount: CurrentBidPrice?
}

struct Seller: Codable {
    let username, feedbackPercentage: String?
    let feedbackScore: Int?
}

struct ShippingOption: Codable {
    let shippingCostType: String?
    let shippingCost: CurrentBidPrice?
}
