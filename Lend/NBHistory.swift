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
    case buyer_sellerConfirm
    case buyer_exchange
    case buyer_returns
    case buyer_finish
    case seller_buyerConfirm
    case seller_sellerConfirm
    case seller_exchange
    case seller_returns
    case seller_finish
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
        " transaction: \(self.transaction?.toString())"
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
            if self.transaction?.getStatus() == .start {
                if responseAccepted() {
                    if self.isMyRequest() {
                        return HistoryStatus.buyer_sellerConfirm
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
                if self.isMyRequest() {
                    return HistoryStatus.buyer_exchange
                }
                else {
                    return HistoryStatus.seller_exchange
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
                if self.isMyRequest() {
                    return HistoryStatus.buyer_returns
                }
                else {
                    return HistoryStatus.seller_returns
                }
            }
            else {
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
    
    static func fetchSelfHistories(_ completionHandler: @escaping (Result<[NBHistory]>) -> Void) {
        Alamofire.request(UsersRouter.getSelfHistory())
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
}
