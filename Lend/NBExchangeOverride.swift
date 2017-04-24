//
//  NBExchangeOverride.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/26/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NBExchangeOverride: ResponseJSONObjectSerializable {
    
    var time: Int64?
    var buyerAccepted: Bool?
    var sellerAccepted: Bool?
    
    required init?(json: SwiftyJSON.JSON) {
        self.time = json["time"].int64
        self.buyerAccepted = json["buyerAccepted"].bool
        self.sellerAccepted = json["sellerAccepted"].bool
    }
    
    init(time: Int64) {
        self.time = time
        self.buyerAccepted = false
        self.sellerAccepted = false
    }
    
    func toString() -> String {
        return "time: \(time)" +
            " buyerAccepted: \(buyerAccepted)" +
            " sellerAccepted: \(sellerAccepted)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let time = time {
            json["time"] = time as AnyObject?
        }
        if let buyerAccepted = buyerAccepted {
            json["buyerAccepted"] = buyerAccepted as AnyObject?
        }
        if let sellerAccepted = sellerAccepted {
            json["sellerAccepted"] = sellerAccepted as AnyObject?
        }
        return json
    }
    
}
