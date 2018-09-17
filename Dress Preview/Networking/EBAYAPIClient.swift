import Foundation

/// Implementation of a generic-based Marvel API client
public class EBAYAPIClient {
    private let oauthToken: String
    
    init(token: String) {
        oauthToken = token
    }
    
    public enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func search(q: String?, completion: @escaping (_ result: Cloth) -> Void) {
        let baseApiUrl = "https://api.ebay.com/buy/browse/v1/item_summary/"
        let api = "search?"
        let q = "q=\(q ?? "")&"
        let category = "15687"
        let uriC0 = "category_ids=\(category)"
        let limitn = "10"
        let uriC1 = "limit=\(limitn)"
        let rek = "\(baseApiUrl)\(api)\(q)\(uriC0)&\(uriC1)"

        guard let url = URL(string: rek) else {
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
