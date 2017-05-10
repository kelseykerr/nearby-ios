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
    
//    let progressHUD = ProgressHUD(text: "Saving")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        ccExpDateTextField.delegate = self
        cvcTextField.delegate = self
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
            if (!(user?.hasAllRequiredFields())!) {
                self.showAlertMsg(message: "You must finish filling out your profile before you can add a credit card")
                return
                
            }
            self.view.endEditing(true)
            
//            progressHUD.show()
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Saving"
            
            //tmp
            // generate creditcard token
            // set that value to user object
            let cardParams = STPCardParams()
            //cardParams.number = "4242424242424242"
            cardParams.number = ccNumberTextField.text
            if ccExpDateTextField.text != nil && (ccExpDateTextField.text?.characters.count)! > 0 {
                let index1 = ccExpDateTextField.text?.index((ccExpDateTextField.text?.endIndex)!, offsetBy: -3)
                let month = ccExpDateTextField.text?.substring(to: index1!)
                cardParams.expMonth = UInt(month!)!
                let index2 = ccExpDateTextField.text?.index((ccExpDateTextField.text?.endIndex)!, offsetBy: -2)
                let year = ccExpDateTextField.text?.substring(from: index2!)
                let expYear = 2000 + UInt(year!)!
                cardParams.expYear = expYear
            }
            cardParams.cvc = cvcTextField.text
            
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
                        self.delegate?.refreshStripeInfo()
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



    
}
