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
    
    var alertController: UIAlertController?
    
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
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        UserManager.sharedInstance.getUser { user in
            self.user = user
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    func canSave() -> Bool {
        return nameTextField.text != "" && accountNumberTextField.text != "" && routingNumberTextField.text != ""
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

        user.bankAccountNumber = accountNumber
        user.bankRoutingNumber = routingNumber
        user.fundDestination = "bank"
        
        self.view.endEditing(true)
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Saving"
        
        NBStripe.addBank(user) { error in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            if let error = error {
                let alert = Utils.createServerErrorAlert(error: error)
                self.present(alert, animated: true, completion: nil)
            }
            
            UserManager.sharedInstance.fetchUser { user in
                print("updated user")
                self.delegate?.refreshStripeInfo()
            }
        }
    }
    
    func showAlertMessage(message: String) {
        let alert = Utils.createErrorAlert(errorMessage: message)
        self.present(alert, animated: true, completion: nil)
    }
    
}

