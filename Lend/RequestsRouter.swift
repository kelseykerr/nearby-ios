//
//  RequestsRouter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/17/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire

enum RequestsRouter: URLRequestConvertible {
    static let baseURLString = NBConstants.baseURLString

    case getRequests(Double, Double, Double, Bool, Bool, String, String) // latitude, longitude, radius, includeWanted, includeOffered, searchTerm, sort
    case getRequest(String)
    case createRequest([String: AnyObject])
    case deleteRequest(String)
    case editRequest(String, [String: AnyObject])
    case getAtPath(String)
    case getResponses(String)
    case getResponse(String, String)
    case createResponse(String, [String: AnyObject])
    case editResponse(String, String, [String: AnyObject])
    case getNotifications(Double, Double)
    case flagRequest(String, [String: AnyObject])
    case flagResponse(String, String, [String: AnyObject])
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        var method: Alamofire.HTTPMethod {
            switch self {
            case .getRequests, .getRequest, .getAtPath, .getResponses, .getResponse, .getNotifications:
                return .get
            case .createRequest, .createResponse, .flagRequest, .flagResponse:
                return .post
            case .deleteRequest:
                return .delete
            case .editRequest, .editResponse:
                return .put
            }
        }
        
        let url: URL = {
            let relativePath: String?
            switch self {
            case .getRequests(let latitude, let longitude, let radius, let includeWanted, let includeOffered, let searchTerm, let sort):
                var additionalParams = ""
                if includeWanted && !includeOffered {
                    additionalParams.append("&type=requests")
                }
                else if !includeWanted && includeOffered {
                    additionalParams.append("&type=offers")
                }
                relativePath = "requests?longitude=\(longitude)&latitude=\(latitude)&radius=\(radius)&searchTerm=\(searchTerm)&sort=\(sort)&includeMine=false\(additionalParams)"
            case .getRequest(let id):
                relativePath = "requests/\(id)"
            case .getAtPath(let path):
                // already have the full URL, so just return it
                return Foundation.URL(string: path)!
            case .createRequest:
                relativePath = "requests"
            case .deleteRequest(let id):
                relativePath = "requests/\(id)"
            case .editRequest(let id, _):
                relativePath = "requests/\(id)"
            case .getResponses(let requestId):
                relativePath = "requests/\(requestId)/responses"
            case .getResponse(let requestId, let responseId):
                relativePath = "requests/\(requestId)/responses/\(responseId)"
            case .createResponse(let requestId, _):
                relativePath = "requests/\(requestId)/responses"
            case .editResponse(let requestId, let responseId, _):
                relativePath = "requests/\(requestId)/responses/\(responseId)"
            case .getNotifications(let latitude, let longitude):
                relativePath = "requests/notifications?longitude=\(longitude)&latitude=\(latitude)"
            case .flagRequest(let id, let _):
                relativePath = "requests/\(id)/flags"
            case .flagResponse(let requestId, let responseId, let _):
                relativePath = "requests/\(requestId)/responses/\(responseId)/flags"
            }
            
            // use NSURLComponents
            var URL = Foundation.URL(string: RequestsRouter.baseURLString)!
            if let relativePath = relativePath {
                let escapedAddress = relativePath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) as String?
                URL = Foundation.URL(string: RequestsRouter.baseURLString + escapedAddress!)!
            }
            return URL
        }()
        
        let params: ([String: AnyObject]?) = {
            switch self {
            case .getRequests, .getRequest, .getAtPath, .deleteRequest, .getResponses, .getResponse, .getNotifications:
                return nil
            case .createRequest(let newItem):
                return (newItem)
            case .createResponse(_, let newItem):
                return (newItem)
            case .editRequest(_ , let newItem):
                return (newItem)
            case .editResponse(_, _, let newItem):
                return (newItem)
            case .flagRequest(_, let newItem):
                return (newItem)
            case .flagResponse(_, _, let newItem):
                return (newItem)
            }
        }()
        
        var urlRequest = URLRequest(url: url)
        let tokenString = NewAccountManager.sharedInstance.getOAuthTokenString()
        urlRequest.setValue(tokenString, forHTTPHeaderField: "x-auth-token")
        
        let authMethod = NewAccountManager.sharedInstance.getAuthMethod()
        urlRequest.setValue(authMethod, forHTTPHeaderField: "x-auth-method")
        
        urlRequest = try Alamofire.JSONEncoding.default.encode(urlRequest, with: params)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
