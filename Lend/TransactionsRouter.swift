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
    static let baseURLString = "http://ec2-54-152-71-22.compute-1.amazonaws.com/api/"
    
    case getTransaction(String)
//    case deleteTransaction(String)
//    case getTransactionCode(String)
//    case putTransactionCode(String)
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
//            case .getTransaction, .getTransactionCode:
            case .getTransaction:
                return .get
//            case .putTransactionCode, .putTransactionExchange, .putTransactionPrice:
//                return .put
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
//            case .getTransactionCode(let id):
//                relativePath = "transactions/\(id)/code"
//            case .putTransactionCode(let id, let code):
//                relativePath = "transactions/\(id)/code/\(code)"
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
            case .getTransaction:
                return nil
//            case .getTransaction, .getTransactionCode:
//                return nil
//            case .putTransactionCode, .putTransactionExchange, .putTransactionPrice:
//                return ??? // return the param?
//            case .postTransactionExchange:
//                return ??? // return the param?
//            case .deleteTransaction: // move this up with get?
//                return nil
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let tokenString = AccountManager.sharedInstance.getOAuthTokenString()
        urlRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
        
        urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
//        let URLRequest = NSMutableURLRequest(url: url)
//        let tokenString = AccountManager.sharedInstance.getOAuthTokenString()
//        URLRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
//        
//        let encoding = Alamofire.JSONEncoding.default
//        let (encodingRequest, _) = encoding.encode(URLRequest, with: params)
//        
//        encodingRequest.httpMethod = method.rawValue
//        
//        return encodingRequest
    }
}
