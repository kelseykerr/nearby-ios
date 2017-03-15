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
    
    let progressHUD = ProgressHUD(text: "Saving")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.view.addSubview(progressHUD)
        progressHUD.hide()
        
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
//            user?.bankAccountNumber = "1123581321"
//            user?.bankRoutingNumber = "071101307"
            user?.bankAccountNumber = "000123456789"
            user?.bankRoutingNumber = "110000000"
            user?.fundDestination = "bank"
            
            print(user?.toString())
            
            progressHUD.show()
            
//            NBUser.editSelf(user!, completionHandler: { error in
//                if (error != nil) {
//                    print("there was an error")
//                }
//                else {
//                    print("no error")
//                }
//            })
            
            NBStripe.addBank(user!, completionHandler: { response in
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

