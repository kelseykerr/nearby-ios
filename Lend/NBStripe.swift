//
//  NBStripe.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// Do we even need a class for this???
class NBStripe: ResponseJSONObjectSerializable {
    
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

extension NBStripe {
    
    static func addBank(_ user: NBUser, completionHandler: @escaping (DataResponse<Any>) -> Void) {
        Alamofire.request(StripeRouter.createBank(user.toJSON())).validate(statusCode: 200..<300).responseJSON { response in
            print(JSON(user.toJSON()))
            print(response.response)
            completionHandler(response)
        }
    }
    
    static func addCreditcard(_ user: NBUser, completionHandler: @escaping (DataResponse<Any>) -> Void) {
        Alamofire.request(StripeRouter.createCreditcard(user.toJSON())).validate(statusCode: 200..<300).responseJSON { response in
            print(JSON(user.toJSON()))
            print(response.response)
            completionHandler(response)
        }
    }
    
}
