//
//  SearchFilter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 12/29/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation


//turn this into struct and force to pass by value not by ref
//may require some change in view controllers
class SearchFilter {
    
    var searchTerm: String
    
    var includeWanted: Bool
    
    var includeOffered: Bool
    
    var sortBy: String
    
    var searchBy: String
    
    var searchRadius: Double
    
    init() {
        //init with default values
        self.searchTerm = ""
        self.includeWanted = true
        self.includeOffered = true
        self.sortBy = "newest"
        self.searchBy = "current location"
        self.searchRadius = 10.0
    }
    
}

