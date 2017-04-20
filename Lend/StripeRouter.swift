//
//  StripeRouter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire

enum StripeRouter: URLRequestConvertible {
    static let baseURLString = "https://alpha-server.thenearbyapp.com/api/"
//    static let baseURLString = "https://server.thenearbyapp.com/api/"
    
    case createBank([String: AnyObject])
    case createCreditcard([String: AnyObject])
    case createWebhooks([String: AnyObject])
    
    public func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod {
            switch self {
            case .createWebhooks, .createBank, .createCreditcard:
                return .post
            }
        }
        
        let url: URL = {
            let relativePath: String?
            switch self {
            case .createWebhooks:
                relativePath = "stripe/webhooks"
            case .createBank:
                relativePath = "stripe/bank"
            case .createCreditcard:
                relativePath = "stripe/creditcard"
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
            case .createWebhooks(let newItem):
                return (newItem)
            case .createBank(let newItem):
                return (newItem)
            case .createCreditcard(let newItem):
                return (newItem)
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let tokenString = AccountManager.sharedInstance.getOAuthTokenString()
        urlRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
        
        let authMethod = AccountManager.sharedInstance.getAuthMethod()
        urlRequest.setValue(authMethod, forHTTPHeaderField: "x-auth-method")
        
        urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
