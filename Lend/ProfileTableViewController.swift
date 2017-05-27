//
//  ProfileTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 11/12/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MBProgressHUD
import DropDown

class ProfileTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailAddressTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var dateOfBirthTextField: UITextField!
    
    @IBOutlet var streetAddressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var zipCodeTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    var user: NBUser?
    
    let birthdatePicker = UIDatePicker()
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        createDatePickers()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        loadCells()
    }
    
    func loadCells() {
        UserManager.sharedInstance.getUser { fetchedUser in
            self.user = fetchedUser
            
            self.firstNameTextField.text = fetchedUser.firstName ?? ""
            self.lastNameTextField.text = fetchedUser.lastName ?? ""
            self.emailAddressTextField.text = fetchedUser.email ?? ""
            self.phoneNumberTextField.text = fetchedUser.phone ?? ""
            self.dateOfBirthTextField.text = fetchedUser.dateOfBirth ?? ""
            
            self.streetAddressTextField.text = fetchedUser.address ?? ""
            self.cityTextField.text = fetchedUser.city ?? ""
            self.stateTextField.text = fetchedUser.state ?? ""
            self.zipCodeTextField.text = fetchedUser.zip ?? ""
        }
    }
    
    func createDatePickers() {
        birthdatePicker.datePickerMode = UIDatePickerMode.date
//        birthdatePicker.maximumDate = Date()
        
        let birthdateToolbar = UIToolbar()
        birthdateToolbar.sizeToFit()
        
        let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let birthdateDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(birthdateDoneButtonPressed))
        birthdateToolbar.setItems([spaceBarItem, birthdateDoneButton], animated: false)
        
        dateOfBirthTextField.inputAccessoryView = birthdateToolbar
        dateOfBirthTextField.inputView = birthdatePicker
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func birthdateDoneButtonPressed() {
        dateOfBirthTextField.text = dateFormatter.string(from: birthdatePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField {
            let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return formattedPhoneNumber(replacementString: string, str: str)

        }
        return true
    }
    
    func formattedPhoneNumber(replacementString: String?, str: String?) -> Bool {
        let digits = NSCharacterSet.decimalDigits
        for uni in (replacementString?.unicodeScalars)! {
            if (uni == "-" && (str!.characters.count != 4 && str!.characters.count != 8)) {
                return false
            } else if (!digits.contains(uni) && uni != "-") {
                return false
            }
          
        }
        if (replacementString == "") { //BackSpace
            return true
        } else if (str!.characters.count == 4) && replacementString != "-" {
            phoneNumberTextField.text = (phoneNumberTextField.text! + "-")
        } else if str!.characters.count == 8 && replacementString != "-" {
            phoneNumberTextField.text = (phoneNumberTextField.text! + "-")
        } else if (str!.characters.count > 12) {
            return false
        }
        
        return true
    }
    
    func saveCells() {
        if user != nil {
            user?.firstName = self.firstNameTextField.text
            user?.lastName = self.lastNameTextField.text
            user?.email = self.emailAddressTextField.text
            user?.phone = self.phoneNumberTextField.text
            user?.dateOfBirth = self.dateOfBirthTextField.text
            
            user?.address = self.streetAddressTextField.text
            user?.city = self.cityTextField.text
            var state = self.stateTextField.text
            state = state?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
            if (state == "D.C.") {
                state = "DC"
            }
            
            user?.state = state
            user?.zip = self.zipCodeTextField.text
            
            self.view.endEditing(true)
            
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Saving"
            
            NBUser.editSelf(user!) { (result, error) in
                loadingNotification.hide(animated: true)
//                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                guard error == nil else {
                    let alert = Utils.createServerErrorAlert(error: error! as NSError)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                guard let editedUser = result.value else {
                    print("no value was returned")
                    return
                }
                UserManager.sharedInstance.user = editedUser
                self.user = editedUser
                
            }
        }
    }

}
