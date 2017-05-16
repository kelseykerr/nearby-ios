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
                let tosString = self.EULA_STRING + "Payment processing services for sellers on Nearby are provided by Stripe and are subject to the Stripe Connected Account Agreement, which includes the Stripe Terms of Service (collectively, the “Stripe Services Agreement”). By agreeing to these terms or continuing to operate as a user on Nearby, you agree to be bound by the Stripe Services Agreement, as the same may be modified by Stripe from time to time. As a condition of Nearby enabling payment processing services through Stripe, you agree to provide Nearby accurate and complete information about you and your business, and you authorize Nearby to share it and transaction information related to your use of the payment processing services provided by Stripe."
                
                let alert = UIAlertController(title: "End User Liscense Agreement & Terms of Service", message: tosString, preferredStyle: UIAlertControllerStyle.alert)
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
    
    let text: String = "test \n text text"
    
    

    let EULA_STRING: String = "Nearby App End User License Agreement \n This End User License Agreement (\"Agreement\") is between you and Nearby and governs use of this app made available through the Apple App Store. By installing the Nearby App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content. If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the Nearby App. \n In order to ensure Nearby provides the best experience possible for everyone, we strongly enforce a no tolerance policy for objectionable content. If you see inappropriate content, please use the \"Report\" feature found under each post. \n 1. Parties \n This Agreement is between you and Nearby only, and not Apple, Inc. (\"Apple\"). Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries are third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. Nearby, not Apple, is solely responsible for the Nearby App and its content. \n 2.Privacy \n Nearby may collect and use information about your usage of the Nearby App, including certain types of information from and about your device. Nearby may use this information, as long as it is in a form that does not personally identify you, to measure the use and performance of the Nearby App. \n 3. Objectionable Content Policy \n We  will moderate all content and ultimately decide whether to remove content to the extent such content includes, is in conjunction with, or alongside any, Objectionable Content. Objectionable Content includes, but is not limited to: (i) sexually explicit materials; (ii) obscene, defamatory, libelous, slanderous, violent and/or unlawful content or profanity; (iii) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, or that is deceptive or fraudulent; (iv) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms; and (v) gambling, including without limitation, any online casino, sports books, bingo or poker. \n 4. Warranty \n Nearby disclaims all warranties about the Nearby App to the fullest extent permitted by law. To the extent any warranty exists under law that cannot be disclaimed, Nearby, not Apple, shall be solely responsible for such warranty. \n 5. Maintenance and Support \n Nearby does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required by applicable law, Nearby, not Apple, shall be obligated to furnish any such maintenance or support. \n 6. Third Party Intellectual Property Claims \n Nearby shall not be obligated to indemnify or defend you with respect to any third party claim arising out or relating to the Nearby App. To the extent Nearby is required to provide indemnification by applicable law, Nearby, not Apple, shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the Nearby App or your use of it infringes any third party intellectual property right.\n \n"
}
