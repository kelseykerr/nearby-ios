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
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var accountNumberTextField: UITextField!
    @IBOutlet var routingNumberTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    var delegate: UpdateBankInfoDelegate?
    
    var user: NBUser?
    
    var name: String? {
        get {
            return nameTextField.text
        }
        set {
            nameTextField.text = newValue
        }
    }
    
    var accountNumber: String? {
        get {
            return accountNumberTextField.text
        }
        set {
            accountNumberTextField.text = newValue
        }
    }
    
    var routingNumber: String? {
        get {
            return routingNumberTextField.text
        }
        set {
            routingNumberTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        UserManager.sharedInstance.getUser { user in
            self.user = user
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    func canSave() -> Bool {
        return name != "" && accountNumber != "" && routingNumber != ""
    }
    
    func saveCells() {
        guard let user = user, canSave() else {
            self.showAlertMessage(message: "All fields must be filled before you can add a bank account")
            return
        }
        
        guard user.hasAllRequiredFields() else {
            self.showAlertMessage(message: "You must finish filling out your profile before you can add a bank account")
            return
        }

        self.view.endEditing(true)
        
        let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Saving")
        
        user.bankAccountNumber = accountNumber
        user.bankRoutingNumber = routingNumber
        user.fundDestination = "bank"
        
        NBStripe.addBank(user) { error in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            if let error = error {
                let alert = Utils.createServerErrorAlert(error: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            UserManager.sharedInstance.fetchUser { user in
                print("updated user")
                self.delegate?.refreshStripeInfo()
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

