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

protocol UpdatePaymentInfoDelegate {
    
    func refreshStripeInfo()
    
}

class PaymentTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var nameOnCardTextField: UITextField!
    @IBOutlet var ccNumberTextField: UITextField!
    @IBOutlet var ccExpDateTextField: UITextField!
    @IBOutlet var cvcTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    var alertController: UIAlertController?
    
    var user: NBUser?
    
    var delegate: UpdatePaymentInfoDelegate?
    
    var name: String? {
        get {
            return nameOnCardTextField.text
        }
        set {
            nameOnCardTextField.text = newValue
        }
    }
    
    var ccNumber: String? {
        get {
            return ccNumberTextField.text
        }
        set {
            ccNumberTextField.text = newValue
        }
    }
    
    var ccExpDate: String? {
        get {
            return ccExpDateTextField.text
        }
        set {
            ccExpDateTextField.text = newValue
        }
    }
    
    var cvc: String? {
        get {
            return cvcTextField.text
        }
        set {
            cvcTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        ccExpDateTextField.delegate = self
        cvcTextField.delegate = self
        
        UserManager.sharedInstance.getUser { user in
            self.user = user
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    func canSave() -> Bool {
        return name != "" && ccNumber != "" && ccExpDate != "" && cvc != ""
    }
    
    func saveCells() {
        guard let user = user, canSave() else {
            self.showAlertMessage(message: "All fields must be filled before you can add a bank account")
            return
        }
        
        guard user.hasAllRequiredFields() else {
            self.showAlertMessage(message: "You must finish filling out your profile before you can add a credit card")
            return
        }
        
        self.view.endEditing(true)
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Saving"
        
        // generate creditcard token
        // set that value to user object
        let cardParams = STPCardParams()
        cardParams.number = ccNumber
        if let ccExpDate = ccExpDate, ccExpDate.characters.count == 5 {
            let ccExpDateArray = ccExpDate.components(separatedBy: "/")
            let month = UInt(ccExpDateArray[0]) ?? 0
            let year = 2000 + (UInt(ccExpDateArray[1]) ?? 0)
            cardParams.expMonth = month
            cardParams.expYear = year
        }
        cardParams.cvc = cvc
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            if let error = error {
                let alert = Utils.createErrorAlert(errorMessage: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
            }
            
            if let token = token {
                user.stripeCCToken = token.tokenId
                
                NBStripe.addCreditcard(user) { error in
                    
                    if let error = error {
                        let alert = Utils.createServerErrorAlert(error: error)
                        self.present(alert, animated: true, completion: nil)
                    }

                    UserManager.sharedInstance.fetchUser {user in
                        print("updated user")
                        self.delegate?.refreshStripeInfo()
                    }
                }
            }
        }
    }
    
    func showAlertMessage(message: String) {
        let alert = Utils.createErrorAlert(errorMessage: message)
        self.present(alert, animated: true, completion: nil)
    }
    
    ////////////////////////////////////
    //START: THIS NEEDS TO BE CLEANED UP
    ////////////////////////////////////
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == ccExpDateTextField {
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return formattedExpDate(replacementString: string, str: str)
            
        } else if textField == cvcTextField {
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return maxCVC(replacementString: string, str: str)
        }
        return true
    }
    
    func formattedExpDate(replacementString: String?, str: String?) -> Bool {
        let digits = NSCharacterSet.decimalDigits
        for uni in (replacementString?.unicodeScalars)! {
            if (uni == "/" && str!.characters.count != 3) {
                return false
            } else if (!digits.contains(uni) && uni != "/") {
                return false
            }
            
        }
        if (replacementString == "") { //BackSpace
            return true
        } else if (str!.characters.count == 1) && replacementString != "1" && replacementString != "0" {
            ccExpDateTextField.text = (ccExpDateTextField.text! + "0")
        } else if str!.characters.count == 3 && replacementString != "/" {
            ccExpDateTextField.text = (ccExpDateTextField.text! + "/")
        } else if (str!.characters.count > 5) {
            return false
        }
        
        return true
    }
    
    func maxCVC(replacementString: String?, str: String?) -> Bool {
        let digits = NSCharacterSet.decimalDigits
        if (replacementString == "") { //BackSpace
            return true
        } else if (str!.characters.count > 3) {
            return false
        }
        
        return true
    }

    ////////////////////////////////////
    //FINISH: THIS NEEDS TO BE CLEANED UP
    ////////////////////////////////////
    
}
