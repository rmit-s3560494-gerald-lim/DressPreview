//
//  ErrorResponse.swift
//  Dress Preview
//
//  Created by Jean Gabriel GRECO on 18/9/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import Foundation

struct APIErrors: Codable {
    let errors: [Erro]?
}

struct Erro: Codable {
    let errorID: Int?
    let domain, category, message, longMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case errorID = "errorId"
        case domain, category, message, longMessage
    }
}
