//
//  NewAccountManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 4/27/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


enum AccountType {
    case facebook
    case google
    case none
}

//this is not the best but will do for now
//likely use direct injection to switch between different types of account managers?
class NewAccountManager: NSObject {
    
    static let sharedInstance = NewAccountManager()
    
    var accountType: AccountType {
        get {
            if FBSDKAccessToken.current() != nil {
                return .facebook
            }
            else if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                return .google
            }
            else {
                return .none
            }
        }
    }
    
    func hasOAuthToken() -> Bool {
        switch accountType {
        case .facebook:
            return FBSDKAccessToken.current() != nil
        case .google:
            return GIDSignIn.sharedInstance().currentUser != nil
        case .none:
            return false
        }
    }
    
    func getOAuthTokenString() -> String {
        switch accountType {
        case .facebook:
            return FBSDKAccessToken.current().tokenString
        case .google:
            return GIDSignIn.sharedInstance().currentUser.authentication.idToken
        case .none:
            return ""
        }
    }
    
    // maybe also send account type
    func doOAuthLogin(_ fromVC: UIViewController, type: AccountType, completionHandler: @escaping (NSError?) -> Void) {
        switch type {
        case .facebook:
            print("Facebook Login")
            let loginManager = FBSDKLoginManager()
            
            loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: fromVC) { (results, error) in
                completionHandler(error as NSError?)
            }
        case .google:
            print("Google Login")
            GIDSignIn.sharedInstance().signIn()
        case .none:
            print("None Login")
        }
    }
    
    func doLogout(_ fromVC: UIViewController, completionHandler: @escaping (NSError?) -> Void) {
        switch accountType {
        case .facebook:
            let manager = FBSDKLoginManager()
            UserManager.sharedInstance.removeUser()
            manager.logOut()
        case .google:
            UserManager.sharedInstance.removeUser()
            GIDSignIn.sharedInstance().signOut()
        case .none:
            print("do nothing")
        }
        
        //not where it should be but, oh well
        completionHandler(nil)
    }
    
    func getAuthMethod() -> String {
        // return the raw value instead

        switch accountType {
        case .facebook:
            return "facebook"
        case .google:
            return "google"
        case .none:
            return "none"
        }
    }
    
    func signInSilently() {
        switch accountType {
        case .facebook:
            FBSDKAppEvents.activateApp()
        case .google:
            GIDSignIn.sharedInstance().signInSilently()
        case .none:
            print("do nothing")
        }
    }
    
}
