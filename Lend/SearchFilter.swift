//
//  SearchFilter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 12/29/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation

class SearchFilter {
    
    var includeMyRequest: Bool
    
    var includeExpiredRequest: Bool
    
    var sortRequestByDate: Bool
    
    init() {
        self.includeMyRequest = false
        self.includeExpiredRequest = false
        self.sortRequestByDate = false
    }
    
}

