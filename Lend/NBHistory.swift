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
    case buyer_buyerConfirm
    //case buyer_sellerConfirm
    case buyer_exchange
    case buyer_overrideExchange
    case buyer_returns
    case buyer_overrideReturn
    case buyer_priceConfirm
    case buyer_finish
    case buyer_closed
    case seller_buyerConfirm
    case seller_sellerConfirm
    case seller_exchange
    case seller_overrideReturn
    case seller_overrideExchange
    case seller_returns
    case seller_priceConfirm
    case seller_finish
    case seller_closed
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
    }
    
    func toString() -> String {
        return "history" +
        " transaction: \(String(describing: self.transaction?.toString()))"
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
    
    func getResponseById(id: String) -> NBResponse? {
        for response in responses {
            if response.id == id {
                return response
            }
        }
        return nil
    }
    
    func isMyRequest() -> Bool {
        if let isMine = self.request?.isMyRequest() {
            return isMine
        }
        return false
    }
    
    var status: HistoryStatus {
        get {
            // check if request status is closed
            if self.request?.expireDate != nil && (self.request?.expireDate)! < (self.request?.postDate)! {
                if self.isMyRequest() {
                    return HistoryStatus.buyer_closed
                }
                else {
                    return HistoryStatus.seller_closed
                }
            }
            else if self.transaction?.getStatus() == .start {
                if responseAccepted() {
                    if self.isMyRequest() {
                        return HistoryStatus.buyer_buyerConfirm
                    }
                    else {
                        return HistoryStatus.seller_sellerConfirm
                    }
                }
                else {
                    if self.isMyRequest() {
                        return HistoryStatus.buyer_buyerConfirm
                    }
                    else {
                        return HistoryStatus.seller_buyerConfirm
                    }
                }
            }
            else if self.transaction?.getStatus() == .exchange {
                let exchangeOverride = self.transaction?.exchangeOverride
                if self.isMyRequest() {
                    //if there is an exchange override, and I haven't accepted or declined it, show the override for my approval
                    if exchangeOverride != nil && !(exchangeOverride?.buyerAccepted)! && !(exchangeOverride?.declined)! {
                        return HistoryStatus.buyer_overrideExchange
                    } else {
                        return HistoryStatus.buyer_exchange
                    }
                }
                else {
                    //if there is an exchange override and the buyer hasn't accepted or declined it, display the pending status
                    if exchangeOverride != nil && !(exchangeOverride?.buyerAccepted)! && !(exchangeOverride?.declined)! {
                        return HistoryStatus.seller_overrideExchange
                    } else {
                        return HistoryStatus.seller_exchange
                    }
                }
            }
            else if self.transaction?.getStatus() == .returns && (self.request?.rental)! == false {
                if self.isMyRequest() {
                    return HistoryStatus.buyer_finish
                }
                else {
                    return HistoryStatus.seller_finish
                }
            }
            else if self.transaction?.getStatus() == .returns {
                let returnOverride = self.transaction?.returnOverride
                if self.isMyRequest() {
                    if returnOverride != nil && !(returnOverride?.declined)! && !(returnOverride?.sellerAccepted)! {
                        return HistoryStatus.buyer_overrideReturn
                    } else {
                        return HistoryStatus.buyer_returns
                    }
                }
                else {
                    if returnOverride != nil && !(returnOverride?.declined)! && !(returnOverride?.sellerAccepted)! {
                        return HistoryStatus.seller_overrideReturn
                    } else {
                        return HistoryStatus.seller_returns
                    }
                }
            }
            else if self.transaction?.getStatus() == .payment {
                if self.isMyRequest() {
                    return HistoryStatus.buyer_priceConfirm
                }
                else {
                    return HistoryStatus.seller_priceConfirm
                }
            }
            else { // check request is fulfilled
                if self.isMyRequest() {
                    return HistoryStatus.buyer_finish
                }
                else {
                    return HistoryStatus.seller_finish
                }
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
    
    static func fetchSelfHistories(_ completionHandler: @escaping (Result<[NBHistory]>, NSError?) -> Void) {
        Alamofire.request(UsersRouter.getSelfHistory())
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                var error: NSError? = nil
                if response.result.error != nil {
                    let statusCode = response.response?.statusCode
                    let errorMessage = String(data: response.data!, encoding: String.Encoding.utf8)
                    error = NSError(domain: errorMessage!, code: statusCode!, userInfo: nil)
                }
                let result = self.historyArrayFromResponse(response: response)
                completionHandler(result, error)
        }
    }
    
    static func fetchHistories(includeTransaction: Bool, includeRequest: Bool, includeOffer: Bool, includeOpen: Bool, includeClosed: Bool, completionHandler: @escaping (Result<[NBHistory]>, NSError?) -> Void) {
        Alamofire.request(UsersRouter.getHistory(includeTransaction, includeRequest, includeOffer, includeOpen, includeClosed))
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                var error: NSError? = nil
                if response.result.error != nil {
                    let statusCode = response.response?.statusCode
                    let errorMessage = String(data: response.data!, encoding: String.Encoding.utf8)
                    error = NSError(domain: errorMessage!, code: statusCode!, userInfo: nil)
                }
                let result = self.historyArrayFromResponse(response: response)
                completionHandler(result, error)
        }
    }
    
    static func historyArrayFromResponse(response: DataResponse<Any>) -> Result<[NBHistory]> {
        guard response.result.error == nil else {
            print(response.result.error!)
            return .failure(NearbyAPIManagerError.network(error: response.result.error!))
        }
        
        guard let jsonArray = response.result.value as? [[String: Any]] else {
            print("didn't get array of histories object as JSON from API")
            return .failure(NearbyAPIManagerError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        let json = SwiftyJSON.JSON(jsonArray)
        
        var objects = [NBHistory]()
        for (_, item) in json {
            if let object = NBHistory(json: item) {
                objects.append(object)
            }
        }
        return .success(objects)
    }
    
}
