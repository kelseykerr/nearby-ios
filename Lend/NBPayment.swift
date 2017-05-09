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
        return "ccMaskedNumber: \(String(describing: ccMaskedNumber))" +
            " ccExpDate: \(String(describing: ccExpDate))" +
            " destination: \(String(describing: destination))" +
            " bankAccountLast4: \(String(describing: bankAccountLast4))" +
            " routingNumber: \(String(describing: routingNumber))" +
            " email: \(String(describing: email))" +
            " phone: \(String(describing: phone))\n"
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
    
    static func fetchPaymentInfo(completionHandler: @escaping (Result<NBPayment>, NSError?) -> Void) {
        Alamofire.request(UsersRouter.getPaymentInfo())
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                var error: NSError? = nil
                if response.result.error != nil {
                    let statusCode = response.response?.statusCode
                    let errorMessage = String(data: response.data!, encoding: String.Encoding.utf8)
                    error = NSError(domain: errorMessage!, code: statusCode!, userInfo: nil)
                }
                let result = self.paymentObjectFromResponse(response: response)
                completionHandler(result, error)
        }
    }
    
    static func paymentObjectFromResponse(response: DataResponse<Any>) -> Result<NBPayment> {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(NearbyAPIManagerError.network(error: response.result.error!))
        }
        
        guard let jsonObject = response.result.value as? [String: Any] else {
            print("didn't get payment object as JSON from API")
            return .failure(NearbyAPIManagerError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        let json = SwiftyJSON.JSON(jsonObject)
        
        guard let object = NBPayment(json: json) else {
            return .failure(NearbyAPIManagerError.objectSerialization(reason: "Object could not be created from JSON"))
        }
        return .success(object)
    }
    
}
