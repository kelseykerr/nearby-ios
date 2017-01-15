//
//  ProfileTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 11/12/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailAddressTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    
    @IBOutlet var streetAddressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var zipCodeTextField: UITextField!
    
    var user: NBUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCells()
    }
    
    func loadCells() {
        if user != nil {
            self.firstNameTextField.text = user?.firstName ?? ""
            self.lastNameTextField.text = user?.lastName ?? ""
            self.emailAddressTextField.text = user?.email ?? ""
            self.phoneNumberTextField.text = user?.phone ?? ""
            
            self.streetAddressTextField.text = user?.address ?? ""
            self.cityTextField.text = user?.city ?? ""
            self.stateTextField.text = user?.state ?? ""
            self.zipCodeTextField.text = user?.zip ?? ""
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    func saveCells() {
        if user != nil {
            user?.firstName = self.firstNameTextField.text
            user?.lastName = self.lastNameTextField.text
            user?.email = self.emailAddressTextField.text
            user?.phone = self.phoneNumberTextField.text
            
            user?.address = self.streetAddressTextField.text
            user?.city = self.cityTextField.text
            user?.state = self.stateTextField.text
            user?.zip = self.zipCodeTextField.text
            
            //tmp
            user?.paymentMethodNonce = "fake-valid-nonce"
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
            
//            NBBraintree.addCustomer(user!, completionHandler: { error in
//                if (error != nil) {
//                    print("there was an error")
//                }
//                else {
//                    print("no error")
//                }
//            })
            
            NBBraintree.addMerchant(user!, completionHandler: { error in
                if (error != nil) {
                    print("there was an error")
                }
                else {
                    print("no error")
                }
            })
//            NBUser.editSelf(user!, completionHandler: nil)
        }
    }

}
