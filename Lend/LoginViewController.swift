//
//  LoginViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/14/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
    func didTapLoginButton()
}

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    weak var delegate: LoginViewDelegate?
    
    @IBAction func tappedGoogleLogin() {
        tappedLoginButton(type: .google)
    }
    
    @IBAction func tappedLoginButton() {
        tappedLoginButton(type: .facebook)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func tappedLoginButton(type: AccountType) {
        NewAccountManager.sharedInstance.doOAuthLogin(self, type: type) { error in
            if let error = error {
                print(error)
                return
            }
            self.delegate?.didTapLoginButton()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print(error)
            return
        }
        self.delegate?.didTapLoginButton()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }

}
