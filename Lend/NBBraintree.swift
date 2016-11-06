//
//  NBBraintree.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 10/31/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// Do we even need a class for this???
class NBBraintree: ResponseJSONObjectSerializable {
    
    var id: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].string
    }
    
    init(test: Bool) {
        if test {
            self.id = "0"
        }
    }
    
    func toString() -> String {
        return " id: \(id)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let id = id {
            json["id"] = id as AnyObject?
        }
        
        return json
    }
    
}

extension NBBraintree {
    
//    static func fetchToken(completionHandler: /*function pointer goes here*/) {
//        completionHandler()
//    }
    
//    static func createWebhooks() {
//        // not sure what do do here yet, ask Ken/Kelsey
//    }
    
}
