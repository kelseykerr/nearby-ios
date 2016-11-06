//
//  CategoriesManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/31/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation


// what did auto conversion to swift 3 do here???
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class CategoriesManager {
    
    static let sharedInstance = CategoriesManager()
    
    var categories = [NBCategory]()
    
    init() {
        NBCategory.fetchCategories { result in
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let fetchedCategories = result.value else {
                print("no categories fetched")
                return
            }
            
            let sortedCategories = fetchedCategories.sorted { $0.name < $1.name }
            self.categories = sortedCategories
        }
    }
    
}
