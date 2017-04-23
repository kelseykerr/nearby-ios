//
//  AccountManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/31/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation

class AccountManager {
    
    var isFbAuth: Bool!
    
    var isGoogleAuth: Bool!
    
    var googleAuthToken: String!

    static let sharedInstance = AccountManager()
    
    func hasOAuthToken() -> Bool {
        if (self.isFbAuth != nil && self.isFbAuth) {
            return FBSDKAccessToken.current() != nil
        } else {
           return self.isGoogleAuth != nil && self.isGoogleAuth && self.googleAuthToken != nil
        }
    }
    
    func getOAuthTokenString() -> String {
        if (self.isFbAuth != nil && self.isFbAuth) {
            return FBSDKAccessToken.current().tokenString
        } else if (self.isGoogleAuth != nil && self.isGoogleAuth && self.googleAuthToken != nil) {
            return self.googleAuthToken
        } else {
            print("no auth token")
            //return ""
            return FBSDKAccessToken.current().tokenString
        }
    }
    
    func doOAuthLogin(_ fromVC: UIViewController, completionHandler: @escaping (NSError?) -> Void) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile"], from: fromVC) { (results, error) in
            completionHandler(error as NSError?)
        }
    }

    
    func googleSignInSilently() {
        print("silently signing in with google")
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func setGoogleAuth() {
        self.isGoogleAuth = true
        self.isFbAuth = false
    }
    
    func setFbAuth() {
        self.isFbAuth = true
        self.isGoogleAuth = false
    }
    
    func setGoogleAuthToken(token: String) {
        self.googleAuthToken = token
    }
    
    func getAuthMethod() -> String {
        if (self.isGoogleAuth != nil && self.isGoogleAuth) {
            return "google"
        } else {
            return "facebook"
        }
    }
    
}
