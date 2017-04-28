//
//  DirectDepositTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol UpdateBankInfoDelegate {
    
    func refreshStripeInfo()
}

class DirectDepositTableViewController: UITableViewController {
    
//    @IBOutlet var nameOnCardTextField: UITextField!
//    @IBOutlet var ccNumberTextField: UITextField!
//    @IBOutlet var ccExpDateTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    var alertController: UIAlertController?
    
    var delegate: UpdateBankInfoDelegate?
    
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
            
            //tmp
            if (!(user?.hasAllRequiredFields())!) {
                self.showAlertMsg(message: "You must finish filling out your profile before you can add a bank account")
                return
                
            }

            user?.bankAccountNumber = "000123456789"
            user?.bankRoutingNumber = "110000000"
            user?.fundDestination = "bank"
            
            self.view.endEditing(true)
            
//            progressHUD.show()
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.labelText = "Saving"
            
            NBStripe.addBank(user!) { error in
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.delegate?.refreshStripeInfo()
                UserManager.sharedInstance.fetchUser{user in
                    print("updated user")
                }
//                self.progressHUD.hide()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
        }
    }
    
    func showAlertMsg(message: String) {
        guard (self.alertController == nil) else {
            print("Alert already displayed")
            return
        }
        
        self.alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "close", style: .cancel) { (action) in
            print("Alert was cancelled")
            self.alertController=nil;
        }
        
        self.alertController!.addAction(cancelAction)
        
        self.present(self.alertController!, animated: true, completion: nil)
    }
    
}

