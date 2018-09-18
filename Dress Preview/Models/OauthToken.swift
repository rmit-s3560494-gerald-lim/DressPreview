//
//  OauthToken.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 18/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation

struct TokenRequest: Codable {
    let grant_type: String
    let redirect_uri: String
    let scope: String
}
