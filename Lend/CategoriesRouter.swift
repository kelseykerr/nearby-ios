//
//  CategoriesRouter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/23/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire

enum CategoriesRouter: URLRequestConvertible {
    static let baseURLString = "http://ec2-54-152-71-22.compute-1.amazonaws.com/api/"
    
    case getCategories()
    case getCategory(String)
    case createCategory([String: AnyObject])
    case getAtPath(String)
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod {
            switch self {
            case .getCategories, .getCategory, .getAtPath:
                return .get
            case .createCategory:
                return .post
            }
        }
        
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getCategories:
                relativePath = "categories"
            case .getCategory(let id):
                relativePath = "categories/\(id)"
            case .getAtPath(let path):
                // already have the full URL, so just return it
                return Foundation.URL(string: path)!
            case .createCategory:
                relativePath = "categories"
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
            case .getCategories, .getCategory, .getAtPath:
                return nil
            case .createCategory(let newItem):
                return (newItem)
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let tokenString = AccountManager.sharedInstance.getOAuthTokenString()
        urlRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
        
        urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
