//
//  TransactionsRouter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/27/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire

// things are commented out, so I can build, it should mostly be there... few things needs edit
// look into parameters sent back (put and post) so I can build without commenting them out
enum TransactionsRouter: URLRequestConvertible {
    static let baseURLString = "https://alpha-server.thenearbyapp.com/api/"
//    static let baseURLString = "https://server.thenearbyapp.com/api/"
    
    case getTransaction(String)
//    case deleteTransaction(String)
    case getTransactionCode(String)
    case editTransactionCode(String, String)
    case editTransactionPrice(String, [String: AnyObject])
//    case postTransactionExchange(String)
//    case putTransactionExchange(String)
//    case putTransactionPrice(String)
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod {
            switch self {
            case .getTransaction, .getTransactionCode:
                return .get
//            case .putTransactionCode, .putTransactionExchange, .putTransactionPrice:
            case .editTransactionCode, .editTransactionPrice:
                return .put
//            case .postTransactionExchange:
//                return .post
//            case .deleteTransaction:
//                return .delete
            }
        }
        
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getTransaction(let id):
                relativePath = "transactions/\(id)"
//            case .deleteTransaction(let id):
//                relativePath = "transactions/\(id)"
            case .getTransactionCode(let id):
                relativePath = "transactions/\(id)/code"
            case .editTransactionCode(let id, let code):
                relativePath = "transactions/\(id)/code/\(code)"
            case .editTransactionPrice(let id, _):
                relativePath = "transactions/\(id)/price"
//            case .postTransactionExchange(let id):
//                relativePath = "transactions/\(id)/exchange"
//            case .putTransactionExchange(let id):
//                relativePath = "transactions/\(id)/exchange"
//            case .putTransactionPrice(let id):
//                relativePath = "transactions/\(id)/price"
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
            case .getTransaction, .getTransactionCode:
                return nil
//            case .putTransactionCode, .putTransactionExchange, .putTransactionPrice:
            case .editTransactionCode:
                return nil
            case .editTransactionPrice(_, let newItem):
                return (newItem)
//            case .postTransactionExchange:
//                return ??? // return the param?
//            case .deleteTransaction: // move this up with get?
//                return nil
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
