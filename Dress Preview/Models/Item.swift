//
//  Item.swift
//  Dress Preview
//
//  Created by Kunga Kartung on 22/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation
import UIKit

struct Item: Codable {
    let itemID, sellerItemRevision, title, subtitle: String?
    let shortDescription: String?
    let price: Price?
    let categoryPath, condition, conditionID: String?
    let itemLocation: ItemLocation?
    let image: ItemImage?
    let additionalImages: [Image]?
    let marketingPrice: MarketingPrice?
    let color, brand: String?
    let seller: Seller?
    let gtin, mpn, epid: String?
    let estimatedAvailabilities: [EstimatedAvailability]?
    let shippingOptions: [ShippingOption]?
    let shipToLocations: ShipToLocations?
    let returnTerms: ReturnTerms?
    let taxes: [Tax]?
    let localizedAspects: [LocalizedAspect]?
    let quantityLimitPerBuyer: Int?
    let primaryProductReviewRating: PrimaryProductReviewRating?
    let topRatedBuyingExperience: Bool?
    let buyingOptions: [String]?
    let itemAffiliateWebURL, itemWebURL: String?
    let description: String?
    let enabledForGuestCheckout, adultOnly: Bool?
    let categoryID: String?
    var uimage: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case itemID = "itemId"
        case sellerItemRevision, title, subtitle, shortDescription, price, categoryPath, condition
        case conditionID = "conditionId"
        case itemLocation, image, additionalImages, marketingPrice, color, brand, seller, gtin, mpn, epid, estimatedAvailabilities, shippingOptions, shipToLocations, returnTerms, taxes, localizedAspects, quantityLimitPerBuyer, primaryProductReviewRating, topRatedBuyingExperience, buyingOptions
        case itemAffiliateWebURL = "itemAffiliateWebUrl"
        case itemWebURL = "itemWebUrl"
        case description, enabledForGuestCheckout, adultOnly
        case categoryID = "categoryId"
    }
}

struct ItemImage: Codable {
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "imageUrl"
    }
}

struct EstimatedAvailability: Codable {
    let deliveryOptions: [String]?
    let availabilityThresholdType: String?
    let availabilityThreshold: Int?
    let estimatedAvailabilityStatus: String?
    let estimatedSoldQuantity: Int?
}

struct LocalizedAspect: Codable {
    let type: TypeEnum?
    let name, value: String?
}

enum TypeEnum: String, Codable {
    case string = "STRING"
}

struct Price: Codable {
    let value, currency: String?
}

struct PrimaryProductReviewRating: Codable {
    let reviewCount: Int?
    let averageRating: String?
    let ratingHistograms: [RatingHistogram]?
}

struct RatingHistogram: Codable {
    let rating: String?
    let count: Int?
}

struct ReturnTerms: Codable {
    let returnsAccepted: Bool?
    let refundMethod, returnMethod, returnShippingCostPayer: String?
    let returnPeriod: ReturnPeriod?
    let returnInstructions, restockingFeePercentage: String?
}

struct ReturnPeriod: Codable {
    let value: Int?
    let unit: String?
}

struct ShipToLocations: Codable {
    let regionIncluded, regionExcluded: [Region]?
}

struct Region: Codable {
    let regionName, regionType: String?
}

struct ShipToLocationUsedForEstimate: Codable {
    let country: String?
}

struct Tax: Codable {
    let taxJurisdiction: TaxJurisdiction?
    let taxType, taxPercentage: String?
    let shippingAndHandlingTaxed, includedInPrice: Bool?
}

struct TaxJurisdiction: Codable {
    let region: Region?
    let taxJurisdictionID: String?
    
    enum CodingKeys: String, CodingKey {
        case region
        case taxJurisdictionID = "taxJurisdictionId"
    }
}
