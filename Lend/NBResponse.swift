//
//  NBResponse.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/3/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum PriceType: String {
    case flat = "FLAT"
    case per_hour = "PER_HOUR"
    case per_day = "PER_DAY"
}

enum BuyerStatus: String {
    case open = "OPEN"
    case closed = "CLOSED"
    case accepted = "ACCEPTED"
    case declined = "DECLINED"
}

enum SellerStatus: String {
    case offered = "OFFERED"
    case accepted = "ACCEPTED"
    case withdrawn = "WITHDRAWN"
}

enum Status: String {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case closed = "CLOSED"
}

class NBResponse: ResponseJSONObjectSerializable {
    
    var id: String?
    var requestId: String? //REQ
    var sellerId: String? //REQ
    var responseTime: Int64?
    var offerPrice: Float? //REQ
    var priceType: PriceType? //REQ: Should be enum
    var exchangeLocation: String?
    var returnLocation: String?
    var exchangeTime: Int64?
    var returnTime: Int64?
    var buyerStatus: BuyerStatus?
    var sellerStatus: SellerStatus?
    var responseStatus: String?
    var messages = [NBMessage]()
    var seller: NBUser?
    
    required init?(json: SwiftyJSON.JSON) {
        self.id = json["id"].string
        self.requestId = json["requestId"].string
        self.sellerId = json["sellerId"].string
        self.responseTime = json["responseTime"].int64
        self.offerPrice = json["offerPrice"].float
        if let priceTypeString = json["priceType"].string {
            self.priceType = PriceType(rawValue: priceTypeString)
        }
        self.exchangeLocation = json["exchangeLocation"].string
        self.returnLocation = json["returnLocation"].string
        self.exchangeTime = json["exchangeTime"].int64
        self.returnTime = json["returnTime"].int64
        if let buyerStatusString = json["buyerStatus"].string {
            self.buyerStatus = BuyerStatus(rawValue: buyerStatusString)
        }
        if let sellerStatusString = json["sellerStatus"].string {
            self.sellerStatus = SellerStatus(rawValue: sellerStatusString)
        }
        self.responseStatus = json["responseStatus"].string
        for (index, messageJson) in json["messages"] {
//            print("\(index) mess: \(messageJson)")
            //instantiate, check if nil, then append
            messages.append(NBMessage(json: messageJson)!)
        }
        self.seller = NBUser(json: json["seller"])
    }
    
    init(test: Bool) {
        if test {
            self.id = "id"
//            self.requestId = "requestId"
//            self.sellerId = "sellerId"
//            self.responseTime = "responseTime"
//            self.offerPrice = 0
//            self.priceType = "flat"
//            self.exchangeLocation = "exchangeLocation"
//            self.returnLocation = "returnLocation"
//            self.exchangeTime = "exchangeTime"
//            self.returnTime = "returnTime"
//            self.buyerStatus = "buyerStatus"
//            self.sellerStatus = "sellerStatus"
//            self.responseStatus = "responseStatus"
        }
    }
    
    func toString() -> String {
        return "response"
//        return "firstName: \(self.firstName)" +
//            " lastName: \(self.lastName)" +
//            " userId: \(self.userId)" +
//            " fullName: \(self.fullName)" +
//            " id: \(self.id)" +
//            " email: \(self.email)" +
//            " phone: \(self.phone)" +
//            " address: \(self.address)" +
//            " addressLine2: \(self.addressLine2)" +
//            " city: \(self.city)" +
//            " state: \(self.state)" +
//            " zip: \(self.zip)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let id = id {
            json["id"] = id as AnyObject?
        }
        if let requestId = requestId {
            json["requestId"] = requestId as AnyObject?
        }
        if let sellerId = sellerId {
            json["sellerId"] = sellerId as AnyObject?
        }
        if let responseTime = responseTime {
            json["responseTime"] = responseTime as AnyObject?
        }
        if let offerPrice = offerPrice {
            json["offerPrice"] = offerPrice as AnyObject?
        }
        if let priceType = priceType {
            json["priceType"] = priceType.rawValue as AnyObject?
        }
        if let exchangeLocation = exchangeLocation {
            json["exchangeLocation"] = exchangeLocation as AnyObject?
        }
        if let returnLocation = returnLocation {
            json["returnLocation"] = returnLocation as AnyObject?
        }
        if let exchangeTime = exchangeTime {
            json["exchangeTime"] = exchangeTime as AnyObject?
        }
        if let returnTime = returnTime {
            json["returnTime"] = returnTime as AnyObject?
        }
        if let buyerStatus = buyerStatus {
            json["buyerStatus"] = buyerStatus.rawValue as AnyObject?
        }
        if let sellerStatus = sellerStatus {
            json["sellerStatus"] = sellerStatus.rawValue as AnyObject?
        }
        if let responseStatus = responseStatus {
            json["responseStatus"] = responseStatus as AnyObject?
        }
        return json
    }
    
}

extension NBResponse {
    
    static func fetchResponse(_ requestId: String, responseId: String, completionHandler: @escaping (Result<NBResponse>) -> Void) {
        Alamofire.request(RequestsRouter.getResponse(requestId, responseId))
            .responseObject { response in
                completionHandler(response.result)
        }
    }
    
    static func fetchResponses(_ requestId: String, completionHandler: @escaping (Result<[NBResponse]>) -> Void) {
        Alamofire.request(RequestsRouter.getResponses(requestId))
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
    static func editResponse(_ response: NBResponse, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.editResponse(response.requestId!, response.id!, response.toJSON())).response { response in
            completionHandler(response.error as NSError?)
        }
    }
    
    static func addResponse(_ response: NBResponse, completionHandler: @escaping (NSError?) -> Void) {
        print(JSON(response.toJSON()))
        Alamofire.request(RequestsRouter.createResponse(response.requestId!, response.toJSON()))
            .response { response in
                print(response.response)
                completionHandler(response.error as NSError?)
        }
    }
    
}
