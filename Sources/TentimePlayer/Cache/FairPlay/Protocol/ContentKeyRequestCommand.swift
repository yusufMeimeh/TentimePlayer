//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 13/07/2024.
//

import Foundation

protocol ContentKeyRequestCommand {
    func execute(spcData: Data, contentId: String, completion: @escaping (Data?) -> Void)
}

struct ContentKeyRequestFromKSM: ContentKeyRequestCommand {
    func execute(spcData: Data, contentId: String, completion: @escaping (Data?) -> Void) {
        var ckcData: Data? = nil
        
        let spc = spcData.base64EncodedString().replacingOccurrences(of: " ", with: "")
        let contentId = contentId.replacingOccurrences(of: "skd://", with: "")
        let finalStr = "spc=\(spc)&assetId=\(contentId)"
        
        //        print(finalStr)
        // Prepare to get the license i.e. CKC.
        // Make the POST request with customdata set to the authentication XML.
        guard let assetManagerConstantsURL =  URL(string: AssetManagerConstants.drmProxy) else {
            completion(nil)
            return
        }
        var request = URLRequest(url: assetManagerConstantsURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(ContentType.TypeFormURLEncode.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        let jsonData = finalStr.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        session.dataTask(with: request) {data,_,error in
            if let data = data {
                // The response from the KeyOS MultiKey License server may be an error inside JSON.
                do {
                    if error != nil {
                        guard let parsedData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            print("Eror is ", error ?? "")
                            return
                        }
                        let errorId = parsedData["errorid"] as? String
                        let errorMsg = parsedData["errormsg"] as? String
                        print(#function, "License request failed with an error: \(errorMsg ?? "") [\(errorId ?? "")]")
                    }
                }catch {
                    //                print(#function, "The response may be a license. Moving on.")
                    
                }
                guard let data =  Data(base64Encoded: data) else {
                    completion(nil)
                    return
                }
                ckcData = data
            } else {
                print(#function, error?.localizedDescription ?? "Error during CKC request.")
                
            }
            
            completion(ckcData)
            
        }.resume()
        
    }
}
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum ContentType: String {
    case JSON = "application/json"
    case HTML = "text/html"
    case XHTML = "application/xhtml+xml"
    case TypeFormURLEncode = "application/x-www-form-urlencoded"
}
enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}
