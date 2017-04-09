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

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    weak var delegate: LoginViewDelegate?
    
    //@IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    @IBAction func tappedGoogleLogin() {
        print("starting google sign in")
        GIDSignIn.sharedInstance().signIn();
    }
    
    @IBAction func tappedLoginButton() {
//        print("login")
        
        AccountManager.sharedInstance.doOAuthLogin(self) { error in
            if let error = error {
                print(error)
                return
            }
            self.delegate?.didTapLoginButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Automatically sign in the user.
        if (AccountManager.sharedInstance.isGoogleAuth != nil && AccountManager.sharedInstance.isGoogleAuth) {
            print("automatically signing user in with google")
            GIDSignIn.sharedInstance().signInSilently()
        }
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    @IBAction func didTapSignOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
    }
}
