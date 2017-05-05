//
//  UserDataManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 5/5/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

protocol Clearable {

    func clear()
    
}

class UserDataManager {
    
    static let sharedInstace = UserDataManager()
    
    var clearables: [Clearable] = []
    
    func addClearable(_ clearable: Clearable) {
        clearables.append(clearable)
    }
    
    func removeClearable(_ clearable: Clearable) {
        // implement this later, don't need it right now
    }
    
    func clear() {
        for clearable in clearables {
            clearable.clear()
        }
    }
    
}
