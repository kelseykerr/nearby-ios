//
//  PaymentTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit
import Stripe

class PaymentTableViewController: UITableViewController {
    
    @IBOutlet var nameOnCardTextField: UITextField!
    @IBOutlet var ccNumberTextField: UITextField!
    @IBOutlet var ccExpDateTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    var user: NBUser?
    
    let progressHUD = ProgressHUD(text: "Saving")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        self.view.addSubview(progressHUD)
        progressHUD.hide()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.width / 64
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
            
            //tmp
//            user?.paymentMethodNonce = "fake-valid-nonce"
            
            print(user?.toString())
            
            progressHUD.show()
            
            // generate creditcard token
            // set that value to user object
            let cardParams = STPCardParams()
            cardParams.number = "4242424242424242"
            cardParams.expMonth = 10
            cardParams.expYear = 2018
            cardParams.cvc = "123"
            STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
                if let error = error {
                    // show the error to the user
                } else if let token = token {
                    self.user?.stripeCCToken = token.tokenId
                    NBStripe.addCreditcard(self.user!, completionHandler: { response in
                        print(response.result.value)
                        if let error = response.result.error {
                            let statusCode = response.response?.statusCode
                            let alert = UIAlertController(title: "Error", message: "\(statusCode!)", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        self.progressHUD.hide()
                    })
                }
            }

        }
    }
    
}
