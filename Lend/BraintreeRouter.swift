//
//  BraintreeRouter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 10/31/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire

// not sure what to do with this yet,
// this will need to change for sure
//should be called stripe
enum BraintreeRouter: URLRequestConvertible {
    static let baseURLString = "https://alpha-server.thenearbyapp.com/api/"
//    static let baseURLString = "https://server.thenearbyapp.com/api/"
    
    case getToken()
    case createCustomer([String: AnyObject])
    case createMerchant([String: AnyObject])
    case createWebhooks([String: AnyObject])
    case getAtPath(String)
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod {
            switch self {
            case .getToken, .getAtPath:
                return .get
            case .createWebhooks, .createCustomer, .createMerchant:
                return .post
            }
        }
        
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getToken:
                relativePath = "braintree/token"
            case .getAtPath(let path):
                // already have the full URL, so just return it
                return Foundation.URL(string: path)!
            case .createWebhooks:
                relativePath = "braintree/webhooks"
            case .createCustomer:
                relativePath = "braintree/customer"
            case .createMerchant:
                relativePath = "braintree/merchant"
            }
            
            // use NSURLComponents
            var URL = Foundation.URL(string: CategoriesRouter.baseURLString)!
            if let relativePath = relativePath {
                let escapedAddress = relativePath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) as String?
                URL = Foundation.URL(string: CategoriesRouter.baseURLString + escapedAddress!)!
            }
            return URL
        }()
        
        let params: ([String: AnyObject]?) = {
            switch self {
            case .getToken, .getAtPath:
                return nil
            case .createWebhooks(let newItem):
                return (newItem)
            case .createCustomer(let newItem):
                return (newItem)
            case .createMerchant(let newItem):
                return (newItem)
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let tokenString = NewAccountManager.sharedInstance.getOAuthTokenString()
        urlRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
        
        urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
