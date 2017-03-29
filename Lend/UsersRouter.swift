//
//  UsersRouter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/17/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire

// add fcmToken once I figure out what it is :-P
enum UsersRouter: URLRequestConvertible {
    static let baseURLString = "https://alpha-server.thenearbyapp.com/api/"
    //    static let baseURLString = "https://server.thenearbyapp.com/api/"
    
    case getSelf() // myself
    case getSelfRequests()
    case editSelf([String: AnyObject])
    case getSelfHistory()
    case getUser(String)
    case editFcmToken(String)
//    case getPayment()
    //Would be nice to have users in an array
    case getAtPath(String)
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod {
            switch self {
            case .getSelf, .getSelfRequests, .getSelfHistory, .getUser, .getAtPath:
                return .get
            case .editSelf, .editFcmToken:
                return .put
            }
        }
        
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getSelf:
                relativePath = "users/me"
            case .getSelfRequests:
                relativePath = "users/me/requests"
            case .getSelfHistory:
                relativePath = "users/me/history"
            case .editSelf:
                relativePath = "users/me"
            case .editFcmToken(let token):
                relativePath = "users/me/fcmToken/\(token)"
            case .getUser(let id):
                relativePath = "users/\(id)"
            case .getAtPath(let path):
                // already have the full URL, so just return it
                return Foundation.URL(string: path)!
            }
            
            var URL = Foundation.URL(string: UsersRouter.baseURLString)!
            if let relativePath = relativePath {
                URL = URL.appendingPathComponent(relativePath)
            }
            return URL
        }()
        
        let params: ([String: AnyObject]?) = {
            switch self {
            case .getSelf, .getSelfRequests, .getSelfHistory, .getUser, .getAtPath:
                return nil
            case .editSelf(let newItem):
                return (newItem)
            case .editFcmToken:
                return nil
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let tokenString = AccountManager.sharedInstance.getOAuthTokenString()
        urlRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
        
        print(tokenString)
        urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
    
}
