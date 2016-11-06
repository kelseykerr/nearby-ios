//
//  AccountManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/31/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation

class AccountManager {

    static let sharedInstance = AccountManager()
    
    func hasOAuthToken() -> Bool {
        return FBSDKAccessToken.current() != nil
    }
    
    func getOAuthTokenString() -> String {
        return FBSDKAccessToken.current().tokenString
    }
    
    func doOAuthLogin(_ fromVC: UIViewController, completionHandler: @escaping (NSError?) -> Void) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile"], from: fromVC) { (results, error) in
            completionHandler(error as NSError?)
        }
    }
    
}
