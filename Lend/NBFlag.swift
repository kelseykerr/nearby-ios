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
    
    var requestId: String?
    var reporterNotes: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.requestId = json["requestId"].string
        self.reporterNotes = json["reporterNotes"].string
    }
    
    init(requestId: String, reporterNotes: String?) {
        self.requestId = requestId
        self.reporterNotes = reporterNotes
    }
    
    func toString() -> String {
        return "requestId: \(String(describing: requestId))" +
        " reporterNotes: \(String(describing: reporterNotes))\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let requestId = requestId {
            json["requestId"] = requestId as AnyObject?
        }
        if let reporterNotes = reporterNotes {
            json["reporterNotes"] = reporterNotes as AnyObject?
        }
        return json
    }
    
}

extension NBFlag {
    
    static func flag(flag: NBFlag, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.flag(flag.requestId!, flag.toJSON()))
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
