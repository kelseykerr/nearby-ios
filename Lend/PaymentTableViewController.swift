//
//  PaymentTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit
import Stripe
import MBProgressHUD

class PaymentTableViewController: UITableViewController {
    
    @IBOutlet var nameOnCardTextField: UITextField!
    @IBOutlet var ccNumberTextField: UITextField!
    @IBOutlet var ccExpDateTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    var user: NBUser?
    
//    let progressHUD = ProgressHUD(text: "Saving")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

//        self.view.addSubview(progressHUD)
//        progressHUD.hide()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        UserManager.sharedInstance.getUser { user in
            self.user = user
            self.loadCells()
        }
    }
    
    func loadCells() {
        if user != nil {
//            self.nameOnCardTextField.text = user?.firstName ?? ""
//            self.ccNumberTextField.text = user?.lastName ?? ""
//            self.ccExpDateTextField.text = user?.email ?? ""
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    func saveCells() {
        if user != nil {
//            user?.firstName = self.firstNameTextField.text
//            user?.lastName = self.lastNameTextField.text
//            user?.email = self.emailAddressTextField.text
//            user?.phone = self.phoneNumberTextField.text
            
//            progressHUD.show()
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.labelText = "Saving"
            
            //tmp
            // generate creditcard token
            // set that value to user object
            let cardParams = STPCardParams()
            cardParams.number = "4242424242424242"
            cardParams.expMonth = 10
            cardParams.expYear = 2018
            cardParams.cvc = "123"
            
            STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
                if let error = error {
                    let alert = Utils.createErrorAlert(errorMessage: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
//                self.progressHUD.hide()
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                } else if let token = token {
                    self.user?.stripeCCToken = token.tokenId
                    NBStripe.addCreditcard(self.user!) { error in
                        if let error = error {
                            let alert = Utils.createServerErrorAlert(error: error)
                            self.present(alert, animated: true, completion: nil)
                        }
                        UserManager.sharedInstance.fetchUser {user in
                            print("updated user")
                        }
//                self.progressHUD.hide()
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    }
                }
            }

        }
    }
    
}
