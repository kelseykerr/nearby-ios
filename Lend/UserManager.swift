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
        NBUser.fetchSelf { (result, error) in
            guard error == nil else {
                print(error)
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
        NBUser.editSelf(user) { (result, error) in
            guard error == nil else {
                print(error)
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
        NBUser.editSelf(user) { (result, error) in
            guard error == nil else {
                let alert = Utils.createServerErrorAlert(error: error! as NSError)
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
                Ipify.getPublicIPAddress { result in
                    switch result {
                    case .success(let ip):
                        print(ip)
                        user.tosAcceptIp = ip
                        user.tosAccepted = true
                        self.acceptTOS(user: user, vc: vc)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }

            }
        })
    }
    
    let text: String = "test \n text text"
    
}
