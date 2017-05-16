//
//  NBFlag.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 5/15/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NBFlag: ResponseJSONObjectSerializable {
    
    var id: String?
    var reporterNotes: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].string
        self.reporterNotes = json["reporterNotes"].string
    }
    
    init(id: String, reporterNotes: String?) {
        self.id = id
        self.reporterNotes = reporterNotes
    }
    
    func toString() -> String {
        return "id: \(String(describing: id))" +
        " reporterNotes: \(String(describing: reporterNotes))\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let id = id {
            json["id"] = id as AnyObject?
        }
        if let reporterNotes = reporterNotes {
            json["reporterNotes"] = reporterNotes as AnyObject?
        }
        return json
    }
    
}

extension NBFlag {
    
    static func flagRequest(requestId: String, flag: NBFlag, completionHandler: @escaping (NSError?) -> Void) {
        NBFlag.flag(flag: flag, urlRequestConvertible: RequestsRouter.flagRequest(requestId, flag.toJSON()), completionHandler: completionHandler)
    }
    
    static func flagResponse(requestId: String, responseId: String, flag: NBFlag, completionHandler: @escaping (NSError?) -> Void) {
        NBFlag.flag(flag: flag, urlRequestConvertible: RequestsRouter.flagResponse(requestId, responseId, flag.toJSON()), completionHandler: completionHandler)
    }
    
    static func blockUser(userId: String, flag: NBFlag, completionHandler: @escaping (NSError?) -> Void) {
        NBFlag.flag(flag: flag, urlRequestConvertible: UsersRouter.blockUser(userId, flag.toJSON()), completionHandler: completionHandler)
    }
    
    static func flag(flag: NBFlag, urlRequestConvertible: URLRequestConvertible, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(urlRequestConvertible)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                var error: NSError? = nil
                if response.result.error != nil {
                    let statusCode = response.response?.statusCode
                    let errorMessage = String(data: response.data!, encoding: String.Encoding.utf8)
                    error = NSError(domain: errorMessage!, code: statusCode!, userInfo: nil)
                }
                completionHandler(error)
        }
    }
    
}
