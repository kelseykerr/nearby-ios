//
//  NBHistory.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/25/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NBHistory: ResponseJSONObjectSerializable {
    
    var request: NBRequest?
//    var transaction: NBTransaction?
    var responses = [NBResponse]()
    var hidden = false
    
    required init?(json: SwiftyJSON.JSON) {
        self.request = NBRequest(json: json["request"])
//        self.transaction = NBTransaction(json["transaction"])
        for (index, responseJson) in json["responses"] {
            print("\(index) resp: \(responseJson)")
            //instantiate, check if nil, then append
            responses.append(NBResponse(json: responseJson)!)
        }
    }
    
    init(test: Bool) {
//        if test {
//            self.id = "id"
//            self.requestId = "requestId"
//            self.sellerId = "sellerId"
//            self.responseTime = "responseTime"
//            self.offerPrice = 0
//            self.priceType = "flat"
//            self.exchangeLocation = "exchangeLocation"
//            self.returnLocation = "returnLocation"
//            self.exchangeTime = "exchangeTime"
//            self.responseTime = "responseTime"
//            self.buyerStatus = "buyerStatus"
//            self.sellerStatus = "sellerStatus"
//            self.responseStatus = "responseStatus"
//        }
    }
    
    func toString() -> String {
        return "history"
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
        let json = [String: AnyObject]()
//        if let id = id {
//            json["id"] = id
//        }
//        if let requestId = requestId {
//            json["requestId"] = requestId
//        }
//        if let sellerId = sellerId {
//            json["sellerId"] = sellerId
//        }
//        if let responseTime = responseTime {
//            json["responseTime"] = responseTime
//        }
//        if let offerPrice = offerPrice {
//            json["offerPrice"] = offerPrice
//        }
//        if let priceType = priceType {
//            json["priceType"] = priceType
//        }
//        if let exchangeLocation = exchangeLocation {
//            json["exchangeLocation"] = exchangeLocation
//        }
//        if let returnLocation = returnLocation {
//            json["returnLocation"] = returnLocation
//        }
//        if let exchangeTime = exchangeTime {
//            json["exchangeTime"] = exchangeTime
//        }
//        if let responseTime = responseTime {
//            json["responseTime"] = responseTime
//        }
//        if let buyerStatus = buyerStatus {
//            json["buyerStatus"] = buyerStatus
//        }
//        if let sellerStatus = sellerStatus {
//            json["sellerStatus"] = sellerStatus
//        }
//        if let responseStatus = responseStatus {
//            json["responseStatus"] = responseStatus
//        }
        return json
    }
    
}

extension NBHistory {
    
    static func fetchSelfHistories(_ completionHandler: @escaping (Result<[NBHistory]>) -> Void) {
        Alamofire.request(UsersRouter.getSelfHistory())
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
}
