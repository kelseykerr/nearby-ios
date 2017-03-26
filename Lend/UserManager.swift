//
//  UserManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire

//this may eventually move to AccountManager?

class UserManager {
    
    static let sharedInstance = UserManager()
    
    var user: NBUser?
    
    init() {
        //fetch user here?
    }

    func fetchUser(completionHandler: @escaping (NBUser) -> Void) {
        NBUser.fetchSelf { result in
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let fetchedUser = result.value else {
                print("no value was returned")
                return
            }
            
            self.user = fetchedUser
            
            completionHandler(fetchedUser)
        }
    }
    
    func getUser(completionHandler: @escaping (NBUser) -> Void) {
        if self.user != nil {
            completionHandler(self.user!)
        }
        else {
            fetchUser(completionHandler: { fetchedUser in
                completionHandler(fetchedUser)
            })
        }
    }
    
    func editUser(user: NBUser, completionHandler: @escaping (NSError?) -> Void) {
        self.user = user
        
        NBUser.editSelf(user) { error in
            completionHandler(error)
        }
    }
    
    func userAvailable() -> Bool {
        return user != nil
    }
    
}
