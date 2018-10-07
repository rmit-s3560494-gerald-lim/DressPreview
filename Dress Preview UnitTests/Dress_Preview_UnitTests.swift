//
//  Dress_Preview_UnitTests.swift
//  Dress Preview UnitTests
//
//  Created by Gerald Lim on 2/10/18.
//  Copyright © 2018 🍆. All rights reserved.
//

import XCTest
@testable import Dress_Preview
@testable import Disk

class Dress_Preview_UnitTests: XCTestCase {
    
    var ebayClient: EBAYAPIClient!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ebayClient = EBAYAPIClient(token: "Bearer <No token>")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ebayClient = nil
        super.tearDown()
    }
    
    func testRefreshTokenTest() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.ebay.com"
        
        // Create an expectation
        let expectation = self.expectation(description: "refreshToken")
        
        components.path = "/identity/v1/oauth2/token"
        guard let url = components.url else {
            print(EBAYApiError.cantCreateUrl)
            XCTAssertFalse(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic SmVhbkdhYnItRHJlc3NQcmUtUFJELTBlZDU5YmZkOC02MGQwOWYzNzpQUkQtZWQ1OWJmZDg5MDdiLWJiYTYtNDNlMS1hMmFhLTc0Mzk=", forHTTPHeaderField: "Authorization")
        let grant = "grant_type=client_credentials&redirect_uri=Jean_Gabriel_GR-JeanGabr-DresP-qffwgq&scope=https://api.ebay.com/oauth/api_scope"
        let toto: Data? = grant.data(using: .utf8) // non-nil
        request.httpBody = toto
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            if let error = responseError {
                print(error)
                return
            } else if let jsonData = responseData {
                let decoder = JSONDecoder()
                do {
                    let oauthResponse = try? decoder.decode(OauthResponse.self, from: jsonData)
                    if (oauthResponse == nil){
                        let errors = try? decoder.decode(OauthError.self, from: jsonData)
                        if errors != nil {
                            print("token not received \(String(describing: errors))")
                        }
                        expectation.fulfill()
//                        completion(.failure(errors as Any))
                    }
                    else {
                        print("token received \(String(describing: oauthResponse))")
                        self.ebayClient.oauthToken = "Bearer <\(oauthResponse!.accessToken)>"
                        let d = Date().timeIntervalSinceReferenceDate + 7200
                        let te = TokenExpiry(expiryDate: d)
                        print("try to save token to a file")
                        try Disk.save(te, to: .caches, as: "TokenExpiry.json")
                        try Disk.save(oauthResponse, to: .caches, as: "OauthToken.json")
                        expectation.fulfill()
//                        completion(.success(oauthResponse as Any))
                    }
                } catch {
                    print(error)
                    return
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                print(error)
                return
            }
        }
        task.resume()
        
        waitForExpectations(timeout: 5, handler: nil)
        
    }
}
