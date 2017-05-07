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
    case getHistory(Bool, Bool, Bool, Bool, Bool)
    case getUser(String)
    case editFcmToken(String)
    case getPaymentInfo()
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
            case .getSelf, .getSelfRequests, .getSelfHistory, .getUser, .getAtPath, .getPaymentInfo, .getHistory:
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
            case .getHistory(let includeTransaction, let includeRequest, let includeOffer, let includeOpen, let includeClosed):
                var paramStrings: [String] = []
                
                if includeTransaction {
                    paramStrings.append("types=transactions")
                }
                if includeRequest {
                    paramStrings.append("types=resquests")
                }
                if includeOffer {
                    paramStrings.append("types=offers")
                }
                
                if includeOpen {
                    paramStrings.append("status=open")
                }
                if includeClosed {
                    paramStrings.append("status=closed")
                }
                
                var additionalRelativeString: String = ""
                for (i, paramString) in paramStrings.enumerated() {
                    if i == 0 {
                        additionalRelativeString = "?\(paramString)"
                    }
                    else {
                        additionalRelativeString = "\(additionalRelativeString)&\(paramString)"
                    }
                }
                
                relativePath = "users/me/history\(additionalRelativeString)"
                
            case .editSelf:
                relativePath = "users/me"
            case .editFcmToken(let token):
                relativePath = "users/me/fcmToken/\(token)"
            case .getUser(let id):
                relativePath = "users/\(id)"
            case .getPaymentInfo:
                relativePath = "users/me/payments"
            case .getAtPath(let path):
                // already have the full URL, so just return it
                return Foundation.URL(string: path)!
            }
            
            // use NSURLComponents
            var URL = Foundation.URL(string: RequestsRouter.baseURLString)!
            if let relativePath = relativePath {
                let escapedAddress = relativePath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) as String?
                URL = Foundation.URL(string: RequestsRouter.baseURLString + escapedAddress!)!
            }
            return URL
//            var URL = Foundation.URL(string: UsersRouter.baseURLString)!
//            if let relativePath = relativePath {
//                URL = URL.appendingPathComponent(relativePath)
//            }
//            return URL
        }()
        
        let params: ([String: AnyObject]?) = {
            switch self {
            case .getSelf, .getSelfRequests, .getSelfHistory, .getUser, .getAtPath, .getPaymentInfo, .getHistory:
                return nil
            case .editSelf(let newItem):
                return (newItem)
            case .editFcmToken:
                return nil
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let tokenString = NewAccountManager.sharedInstance.getOAuthTokenString()
        urlRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
        
        let authMethod = NewAccountManager.sharedInstance.getAuthMethod()
        urlRequest.setValue(authMethod, forHTTPHeaderField: "x-auth-method")
        
        print(tokenString)
        urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
    
}
