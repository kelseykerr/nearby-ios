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

enum HistoryStatus {
    case buyerConfirm
    case sellerConfirm
    case exchange
    case returns
    case finish
}

class NBHistory: ResponseJSONObjectSerializable {
    
    var request: NBRequest?
    var transaction: NBTransaction?
    var responses = [NBResponse]()
    var hidden: Bool? = false
    
    required init?(json: SwiftyJSON.JSON) {
        self.request = NBRequest(json: json["request"])

//        let tran = json["transaction"]
//        if tran != nil {
            self.transaction = NBTransaction(json: json["transaction"])
//        }

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
        return "history" +
        " transaction: \(self.transaction?.toString())"
//        return "firstName: \(self.firstName)" +
//        " lastName: \(self.lastName)" +
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
        
        if let request = request {
            if request.id != nil {
                json["request"] = request.toJSON() as AnyObject?
            }
        }
        if let transaction = transaction {
            if transaction.id != nil {
                json["transaction"] = transaction.toJSON() as AnyObject?
            }
        }

        // responses
        
        if let hidden = hidden {
            json["hidden"] = hidden as AnyObject?
        }
        
        return json
    }
    
}

extension NBHistory {
    
    func isMyRequest() -> Bool {
        return UserManager.sharedInstance.user!.id == self.request!.user!.id
    }
    
    var status: HistoryStatus {
        get {
            if self.transaction?.getStatus() == .start {
                if responseAccepted() {
                    return HistoryStatus.sellerConfirm
                }
                else {
                    return HistoryStatus.buyerConfirm
                }
            }
            else if self.transaction?.getStatus() == .exchange {
                return HistoryStatus.exchange
            }
            else if self.transaction?.getStatus() == .returns {
                return HistoryStatus.returns
            }
            else {
                return HistoryStatus.finish
            }
        }
    }

    func responseAccepted() -> Bool {
        if self.responses.count > 0 {
            for response in responses {
                if response.buyerStatus == .accepted {
                    return true
                }
            }
        }
        return false
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
