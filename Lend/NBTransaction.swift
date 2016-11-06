//
//  NBTransaction.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/26/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NBTransaction: ResponseJSONObjectSerializable {
    
    var id: String?
    var requestId: String?
    var responseId: String?
    var exchanged: Bool?
    var exchangeTime: String?
    var returned: Bool?
    var returnTime: String?
    var exchangeCode: String?
    var returnCode: String?
    var exchangeCodeExpireDate: String?
    var returnCodeExpireDate: String?
    var calculatedPrice: Float?
    var priceOverride: Float?
    var finalPrice: Float?
    var sellerAccepted: Bool?
    var exchangeOverride: NBExchangeOverride?
    var returnOverride: NBExchangeOverride?
    
    required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].string
        self.requestId = json["requestId"].string
        self.responseId = json["responseId"].string
        self.exchanged = json["exchanged"].bool
        self.exchangeTime = json["exchangeTime"].string
        self.returned = json["returned"].bool
        self.returnTime = json["returnTime"].string
        self.exchangeCode = json["exchangeCode"].string
        self.returnCode = json["returnCode"].string
        self.exchangeCodeExpireDate = json["exchangeCodeExpireDate"].string
        self.returnCodeExpireDate = json["returnCodeExpireDate"].string
        self.calculatedPrice = json["calculatedPrice"].float
        self.priceOverride = json["priceOverride"].float
        self.finalPrice = json["finalPrice"].float
        self.sellerAccepted = json["sellerAccepted"].bool
        self.exchangeOverride = NBExchangeOverride(json: json["exchangeOverride"])
        self.returnOverride = NBExchangeOverride(json: json["returnOverride"])
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
        if let requestId = requestId {
            json["requestId"] = requestId as AnyObject?
        }
        if let responseId = responseId {
            json["responseId"] = responseId as AnyObject?
        }
        if let exchanged = exchanged {
            json["exchanged"] = exchanged as AnyObject?
        }
        if let exchangeTime = exchangeTime {
            json["exchangeTime"] = exchangeTime as AnyObject?
        }
        if let returned = returned {
            json["returned"] = returned as AnyObject?
        }
        if let returnTime = returnTime {
            json["returnTime"] = returnTime as AnyObject?
        }
        if let exchangeCode = exchangeCode {
            json["exchangeCode"] = exchangeCode as AnyObject?
        }
        if let returnCode = returnCode {
            json["returnCode"] = returnCode as AnyObject?
        }
        if let exchangeCodeExpireDate = exchangeCodeExpireDate {
            json["exchangeCodeExpireDate"] = exchangeCodeExpireDate as AnyObject?
        }
        if let returnCodeExpireDate = returnCodeExpireDate {
            json["returnCodeExpireDate"] = returnCodeExpireDate as AnyObject?
        }
        if let calculatedPrice = calculatedPrice {
            json["calculatedPrice"] = calculatedPrice as AnyObject?
        }
        if let priceOverride = priceOverride {
            json["priceOverride"] = priceOverride as AnyObject?
        }
        if let finalPrice = finalPrice {
            json["finalPrice"] = finalPrice as AnyObject?
        }
        if let sellerAccepted = sellerAccepted {
            json["sellerAccepted"] = sellerAccepted as AnyObject?
        }
        if let exchangeOverride = exchangeOverride {
            json["exchangeOverride"] = exchangeOverride.toJSON() as AnyObject?
        }
        if let returnOverride = returnOverride {
            json["returnOverride"] = returnOverride.toJSON() as AnyObject?
        }
        
        return json
    }
    
}

// commented out so it will build
// need to create a new response method or use generic one provided by Alamofire
extension NBTransaction {
    
//    static func fetchTransaction(id: String, completionHandler: /*???*/ ) {
//        Alamofire.request(TransactionsRouter.getTransaction(id))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
    
//    static func removeTransaction(id: String, completionHandler: /*???*/) {
//        Alamofire.request(TransactionsRouter.deleteTransaction(id))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
    
//    static func generateTransactionCode(id: String, completionHandler: /*???*/) {
//        Alamofire.request(TransactionsRouter.getTransactionCode(id))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
    
//    static func verifyTransactionCode(id: String, code: String, completionHandler: /*???*/) {
//        Alamofire.request(TransactionsRouter.putTransactionCode(id))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
    
//    static func createTransactionOverride() {
//        Alamofire.request(TransactionsRouter.postTransactionExchange(id))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
    
//    static func verifyTransactionOverride() {
//        Alamofire.request(TransactionsRouter.putTransactionExchange(id))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
    
//    static func verifyTransactionPrice(id: String, price: Double, completionHandler: /*???*/) {
//        Alamofire.request(TransactionsRouter.putTransactionPrice(id))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
    
}
