//
//  UserManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import Ipify
import MBProgressHUD

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
    
    func editUser(user: NBUser, completionHandler: @escaping (NBUser) -> Void) {
        //self.user = user
        
        /*NBUser.editSelf(user) { error in
            completionHandler(error)
        }*/
        NBUser.editSelf(user) { result in
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let editedUser = result.value else {
                print("no value was returned")
                return
            }
            
            self.user = editedUser
            
            completionHandler(editedUser)
        }
        
    }
    
    func removeUser() {
        user = nil
    }
    
    func userAvailable() -> Bool {
        return user != nil
    }
    
    func acceptTOS(user:NBUser, vc: UIViewController) -> () {
        NBUser.editSelf(user) { result in
            guard result.error == nil else {
                let alert = Utils.createServerErrorAlert(error: result.error! as NSError)
                vc.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let editedUser = result.value else {
                print("no value was returned")
                return
            }
            
            self.user = editedUser
            
        }
        
    }
    
    
    func validateProfile(vc: UIViewController) {
        self.getUser(completionHandler: { user in
            if (!user.acceptedTos()) {
                let tosString = "Payment processing services for sellers on Nearby are provided by Stripe and are subject to the Stripe Connected Account Agreement, which includes the Stripe Terms of Service (collectively, the “Stripe Services Agreement”). By agreeing to these terms or continuing to operate as a user on Nearby, you agree to be bound by the Stripe Services Agreement, as the same may be modified by Stripe from time to time. As a condition of Nearby enabling payment processing services through Stripe, you agree to provide Nearby accurate and complete information about you and your business, and you authorize Nearby to share it and transaction information related to your use of the payment processing services provided by Stripe."
                
                let alert = UIAlertController(title: "Terms of Service", message: tosString, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: { action in
                    switch action.style {
                    case .default:
                        print("default")
                        Ipify.getPublicIPAddress { result in
                            switch result {
                            case .success(let ip):
                                print(ip)
                                user.tosAcceptIp = ip
                                user.tosAccepted = true
                                self.acceptTOS(user: user, vc: vc)
                            case .failure(let error):
                                print(error.localizedDescription)
                                user.tosAccepted = true
                                user.tosAcceptIp = "0.0.0.0"
                                self.acceptTOS(user: user, vc: vc)
                            }
                        }
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }
                }))
                vc.present(alert, animated: true, completion: nil)
            }
        })
    }

    
}
