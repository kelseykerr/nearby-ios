//
//  DirectDepositTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class DirectDepositTableViewController: UITableViewController {
    
//    @IBOutlet var nameOnCardTextField: UITextField!
//    @IBOutlet var ccNumberTextField: UITextField!
//    @IBOutlet var ccExpDateTextField: UITextField!
    
    var user: NBUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
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
            user?.bankAccountNumber = "1123581321"
            user?.bankRoutingNumber = "071101307"
            user?.fundDestination = "bank"
            
            print(user?.toString())
            
            NBUser.editSelf(user!, completionHandler: { error in
                if (error != nil) {
                    print("there was an error")
                }
                else {
                    print("no error")
                }
            })
            
            NBBraintree.addMerchant(user!, completionHandler: { error in
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

