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

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, UITextViewDelegate {

    weak var delegate: LoginViewDelegate?
    
    @IBOutlet var termsText: UITextView!
    
    @IBAction func tappedGoogleLogin() {
        tappedLoginButton(type: .google)
    }
    
    @IBAction func tappedLoginButton() {
        tappedLoginButton(type: .facebook)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let termsLinkAttributes = [
            NSLinkAttributeName: NSURL(string: "http://thenearbyapp.com/terms")!,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            NSForegroundColorAttributeName: UIColor.white
            ] as [String : Any]
        
        let privacyLinkAttributes = [
            NSLinkAttributeName: NSURL(string: "http://thenearbyapp.com/privacy")!,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            NSForegroundColorAttributeName: UIColor.white
            ] as [String : Any]
        
        let linkAttributes: [String : Any] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSUnderlineColorAttributeName: UIColor.white,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]

        
        let allAttributes = [NSForegroundColorAttributeName: UIColor.white] as [String : Any]
        
        let attributedString = NSMutableAttributedString(string: "By signing up, I agree to Nearby's Terms of Service, End User License Agreement, and Privacy Policy")
        attributedString.setAttributes(allAttributes, range: NSMakeRange(0, 34))
        attributedString.setAttributes(termsLinkAttributes, range: NSMakeRange(35, 44))
        attributedString.setAttributes(allAttributes, range: NSMakeRange(79, 5))
        attributedString.setAttributes(privacyLinkAttributes, range: NSMakeRange(85, 14))
        self.termsText.linkTextAttributes = linkAttributes
        self.termsText.delegate = self
        self.termsText.attributedText = attributedString
        
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

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }

}
