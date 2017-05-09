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

enum ResponseStatus: String {
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
    var priceType: PriceType? //REQ
    var exchangeLocation: String?
    var returnLocation: String?
    var exchangeTime: Int64?
    var returnTime: Int64?
    var buyerStatus: BuyerStatus?
    var sellerStatus: SellerStatus?
//    var responseStatus: String?
    var responseStatus: ResponseStatus?
    var messages = [NBMessage]()
    var seller: NBUser?
    var description: String?
    var messagesEnabled: Bool?
    
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
        self.description = json["description"].string
        self.messagesEnabled = json["messagesEnabled"].bool
        if let buyerStatusString = json["buyerStatus"].string {
            self.buyerStatus = BuyerStatus(rawValue: buyerStatusString)
        }
        if let sellerStatusString = json["sellerStatus"].string {
            self.sellerStatus = SellerStatus(rawValue: sellerStatusString)
        }
//        self.responseStatus = json["responseStatus"].string
        if let responseStatusString = json["responseStatus"].string {
            self.responseStatus = ResponseStatus(rawValue: responseStatusString)
        }
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
            json["responseStatus"] = responseStatus.rawValue as AnyObject?
        }
        if let description = description {
            json["description"] = description as AnyObject?
        }
        if let messagesEnabled = messagesEnabled {
            json["messagesEnabled"] = messagesEnabled as AnyObject?
        }
        return json
    }
    
    func getElapsedTimeAsString() -> String {
        let seconds = Int(getElapsedTime()!)
        
        if seconds < 60 { // less than a min
            //            return "\(seconds) Secs Ago"
            return "\(seconds)s"
        }
        else if seconds < 3600 { // less than an hour
            //            return "\(seconds / 60) Mins Ago"
            return "\(seconds / 60)m"
        }
        else if seconds < 60 * 60 * 24 { // less than a day
            //            return "\(seconds / (60 * 60)) Hours Ago"
            return "\(seconds / (60 * 60))h"
        }
        else {
            //            return "\(seconds / (60 * 60 * 24)) Days Ago"
            return "\(seconds / (60 * 60 * 24))d"
        }
        
        return "Should not happen"
    }
    
    func getElapsedTime() -> TimeInterval? {
        if let postEpochString = self.responseTime {
            let postEpoch = Double(postEpochString) / 1000
            let postDate = Date(timeIntervalSince1970: postEpoch)
            let elapsedSeconds = Date().timeIntervalSince(postDate)
            return elapsedSeconds
        }
        return nil
    }
    
}

extension NBResponse {
    var priceInDollarFormat: String {
        get {
            let price = self.offerPrice ?? -9.99
            return String(format: "$%.2f", price)
        }
    }
}

extension NBResponse {
    
    static func fetchResponse(_ requestId: String, responseId: String, completionHandler: @escaping (Result<NBResponse>) -> Void) {
        Alamofire.request(RequestsRouter.getResponse(requestId, responseId))
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                let result = self.responseObjectFromResponse(response: response)
                completionHandler(result)
        }
    }
    
    static func fetchResponses(_ requestId: String, completionHandler: @escaping (Result<[NBResponse]>) -> Void) {
        Alamofire.request(RequestsRouter.getResponses(requestId))
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                let result = self.responseArrayFromResponse(response: response)
                completionHandler(result)
        }
    }
    
    static func editResponse(_ response: NBResponse, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.editResponse(response.requestId!, response.id!, response.toJSON()))
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
    
    static func addResponse(_ response: NBResponse, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.createResponse(response.requestId!, response.toJSON()))
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
    
    static func responseObjectFromResponse(response: DataResponse<Any>) -> Result<NBResponse> {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(NearbyAPIManagerError.network(error: response.result.error!))
        }
        
        guard let jsonObject = response.result.value as? [String: Any] else {
            print("didn't get response object as JSON from API")
            return .failure(NearbyAPIManagerError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        let json = SwiftyJSON.JSON(jsonObject)
        
        guard let object = NBResponse(json: json) else {
            return .failure(NearbyAPIManagerError.objectSerialization(reason: "Object could not be created from JSON"))
        }
        return .success(object)
    }
    
    static func responseArrayFromResponse(response: DataResponse<Any>) -> Result<[NBResponse]> {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(NearbyAPIManagerError.network(error: response.result.error!))
        }
        
        guard let jsonArray = response.result.value as? [[String: Any]] else {
            print("didn't get array of responses object as JSON from API")
            return .failure(NearbyAPIManagerError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        let json = SwiftyJSON.JSON(jsonArray)
        
        var objects = [NBResponse]()
        for (_, item) in json {
            if let object = NBResponse(json: item) {
                objects.append(object)
            }
        }
        return .success(objects)
    }
    
}
