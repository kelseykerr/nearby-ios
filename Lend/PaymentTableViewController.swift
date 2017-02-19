//
//  PaymentTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class PaymentTableViewController: UITableViewController {
    
    @IBOutlet var nameOnCardTextField: UITextField!
    @IBOutlet var ccNumberTextField: UITextField!
    @IBOutlet var ccExpDateTextField: UITextField!
    
    var user: NBUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        loadCells()
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
            user?.paymentMethodNonce = "fake-valid-nonce"
            
            print(user?.toString())
            
            NBUser.editSelf(user!, completionHandler: { error in
                if (error != nil) {
                    print("there was an error")
                }
                else {
                    print("no error")
                }
            })
            
            NBBraintree.addCustomer(user!, completionHandler: { error in
                if (error != nil) {
                    print("there was an error")
                }
                else {
                    print("no error")
                }
            })
            
        }
    }
    
}
