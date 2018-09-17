import Foundation

/// Implementation of a generic-based Marvel API client
public class EBAYAPIClient {
    private let oauthToken: String
    var components = URLComponents()
    let baseUrl = "api.ebay.com"
    
    init(token: String) {
        oauthToken = token
        components.scheme = "https"
        self.components.host = "\(baseUrl)"
    }
    
    public enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func search(q: String?, category: String, limit: String?,  completion: @escaping (_ result: Cloth) -> Void) {
        self.components.path = "/buy/browse/v1/item_summary/search"
        let queryItemQ = URLQueryItem(name: "q", value: q)
        let queryItemCategory = URLQueryItem(name: "category_ids", value: category)
        let queryItemlimit = URLQueryItem(name: "limit", value: limit)
        components.queryItems = [queryItemQ, queryItemCategory, queryItemlimit]

        guard let url = components.url else {
            print("Error: cannot create URL")
                return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(self.oauthToken, forHTTPHeaderField: "Authorization")

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
                if let error = responseError {
                    print(error)
                    return
                } else if let jsonData = responseData {
                    // Now we have jsonData, Data representation of the JSON returned to us
                    // from our URLRequest...

                    // Create an instance of JSONDecoder to decode the JSON data to our
                    // Codable struct
                    let decoder = JSONDecoder()

                    do {
                        // We would use Post.self for JSON representing a single Post
                        // object, and [Post].self for JSON representing an array of
                        // Post objects
                        let cloths = try decoder.decode(Cloth.self, from: jsonData)
                        completion(cloths)
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
