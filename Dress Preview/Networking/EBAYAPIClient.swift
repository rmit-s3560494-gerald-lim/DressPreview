import Foundation
import Disk

public class EBAYAPIClient {
    var oauthToken: String
    var components = URLComponents()
    let baseUrl = "api.ebay.com"
    
    init(token: String) {
        oauthToken = token
        components.scheme = "https"
        self.components.host = "\(baseUrl)"
    }
    
    enum Result<Value> {
        case success(Value)
        case failure(Value)
    }
    
    func createUrlRequest(q: String?, category: String, limit: String?)throws -> URLRequest {
        self.components.path = "/buy/browse/v1/item_summary/search"
        let queryItemQ = URLQueryItem(name: "q", value: q)
        let queryItemCategory = URLQueryItem(name: "category_ids", value: category)
        let queryItemlimit = URLQueryItem(name: "limit", value: limit)
        components.queryItems = [queryItemQ, queryItemCategory, queryItemlimit]
        
        guard let url = components.url else {
            print("Error: cannot create URL")
            throw EBAYApiError.cantCreateUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(self.oauthToken, forHTTPHeaderField: "Authorization")
        return request
    }
    
    func getNewToken() throws {
        self.components.path = "/identity/v1/oauth2/token"
        guard let url = components.url else {
            print("Error: cannot create URL")
            throw EBAYApiError.cantCreateUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic SmVhbkdhYnItRHJlc3NQcmUtUFJELTBlZDU5YmZkOC02MGQwOWYzNzpQUkQtZWQ1OWJmZDg5MDdiLWJiYTYtNDNlMS1hMmFhLTc0Mzk=", forHTTPHeaderField: "Authorization")
        let grant = "grant_type=client_credentials&redirect_uri=Jean_Gabriel_GR-JeanGabr-DresP-qffwgq&scope=https://api.ebay.com/oauth/api_scope"
        //let grant = "grant_type=client_credentialsredirect_uri=Jean_Gabriel_GR-JeanGabr-DresP-qffwgqscope=https://api.ebay.com/oauth/api_scope"
        let toto: Data? = grant.data(using: .utf8) // non-nil
        print(toto)
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
                    let oauthResponse = try decoder.decode(OauthResponse.self, from: jsonData)
//                    let errors = try decoder.decode(OauthError.self, from: jsonData)
                    print("token received \(oauthResponse)")
//                    print("token not received \(errors)")
                    self.oauthToken = oauthResponse.accessToken
                    print("try to save token to a file")
                    try Disk.save(oauthResponse, to: .temporary, as: "OauthToken.json")
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
    }
    
    func search(q: String?, category: String, limit: String?,  completion: @escaping (_ result: Result<Any>) -> Void) {
        var request:URLRequest? = nil
        do {
            request = try createUrlRequest(q: q, category: category, limit: limit)
        } catch EBAYApiError.cantCreateUrl {
            print("Can't create URL ")
            return
        } catch {}
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request!) { (responseData, response, responseError) in
                if let error = responseError {
                    print(error)
                    return
                } else if let jsonData = responseData {
                    let decoder = JSONDecoder()

                    do {
                        let cloths = try decoder.decode(Cloth.self, from: jsonData)
                        if (cloths.total == nil)
                        {
                            let errors = try decoder.decode(APIErrors.self, from: jsonData)
                            completion(.failure(errors))
                        }
                        completion(.success(cloths))
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
    }
}
