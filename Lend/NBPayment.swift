//
//  NBPayment.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NBPayment: ResponseJSONObjectSerializable {
    
    var ccMaskedNumber: String?
    var ccExpDate: String?
    var destination: String?
    var bankAccountLast4: String?
    var routingNumber: String?
    var email: String?
    var phone: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.ccMaskedNumber = json["ccMaskedNumber"].string
        self.ccExpDate = json["ccExpDate"].string
        self.destination = json["destination"].string
        self.bankAccountLast4 = json["bankAccountLast4"].string
        self.routingNumber = json["routingNumber"].string
        self.email = json["email"].string
        self.phone = json["phone"].string
    }
    
    func toString() -> String {
        return "ccMaskedNumber: \(ccMaskedNumber)" +
            " ccExpDate: \(ccExpDate)" +
            " destination: \(destination)" +
            " bankAccountLast4: \(bankAccountLast4)" +
            " routingNumber: \(routingNumber)" +
            " email: \(email)" +
            " phone: \(phone)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let ccMaskedNumber = ccMaskedNumber {
            json["ccMaskedNumber"] = ccMaskedNumber as AnyObject?
        }
        if let ccExpDate = ccExpDate {
            json["ccExpDate"] = ccExpDate as AnyObject?
        }
        if let destination = destination {
            json["destination"] = destination as AnyObject?
        }
        if let bankAccountLast4 = bankAccountLast4 {
            json["bankAccountLast4"] = bankAccountLast4 as AnyObject?
        }
        if let routingNumber = routingNumber {
            json["routingNumber"] = routingNumber as AnyObject?
        }
        if let email = email {
            json["email"] = email as AnyObject?
        }
        if let phone = phone {
            json["phone"] = phone as AnyObject?
        }
        return json
    }
    
}

extension NBPayment {
    
    static func fetchPaymentInfo(completionHandler: @escaping (Result<NBPayment>) -> Void) {
        Alamofire.request(UsersRouter.getPaymentInfo())
            .responseObject { paymentInfo in
                completionHandler(paymentInfo.result)
        }

    }
    
}
