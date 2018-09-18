//
//  OauthResponse.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 18/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation

struct OauthResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct OauthError: Codable {
    let error, errorDescription: String
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}
