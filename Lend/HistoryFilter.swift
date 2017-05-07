//
//  HistoryFilter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 5/6/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

class HistoryFilter {
    
    var includeTransaction: Bool
    
    var includeRequest: Bool
    
    var includeOffer: Bool
    
    var includeOpen: Bool
    
    var includeClosed: Bool
    
    init() {
        self.includeTransaction = true
        self.includeRequest = true
        self.includeOffer = true
        self.includeOpen = true
        self.includeClosed = true
    }
    
    var description: String {
        return "Transaction: \(includeTransaction) " +
                "Request: \(includeRequest) " +
                "Offer: \(includeOffer) " +
                "Open: \(includeOpen) " +
                "Closed: \(includeClosed)\n"
    }
    
}
