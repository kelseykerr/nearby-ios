//
//  ProfileTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 11/12/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MBProgressHUD


protocol AccountDelegate {
    
    func updated(user: NBUser?)
    
}

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
    
    var delegate: AccountDelegate?
    
    var user: NBUser?
    
    let birthdatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    var firstName: String? {
        get {
            return firstNameTextField.text
        }
        set {
            firstNameTextField.text = newValue
        }
    }
    
    var lastName: String? {
        get {
            return lastNameTextField.text
        }
        set {
            lastNameTextField.text = newValue
        }
    }
    
    var emailAddress: String? {
        get {
            return emailAddressTextField.text
        }
        set {
            emailAddressTextField.text = newValue
        }
    }
    
    var phoneNumber: String? {
        get {
            return phoneNumberTextField.text
        }
        set {
            phoneNumberTextField.text = newValue
        }
    }
    
    var dateOfBirth: String? {
        get {
            return dateOfBirthTextField.text
        }
        set {
            dateOfBirthTextField.text = newValue
        }
    }
    
    var streetAddress: String? {
        get {
            return streetAddressTextField.text
        }
        set {
            streetAddressTextField.text = newValue
        }
    }
    
    var city: String? {
        get {
            return cityTextField.text
        }
        set {
            cityTextField.text = newValue
        }
    }
    
    var state: String? {
        get {
            return stateTextField.text
        }
        set {
            stateTextField.text = newValue
        }
    }
    
    var zipCode: String? {
        get {
            return zipCodeTextField.text
        }
        set {
            zipCodeTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        phoneNumberTextField.delegate = self
        
        createBirthdatePicker()
        
        loadCells()
    }
    
    func loadCells() {
        UserManager.sharedInstance.getUser { fetchedUser in
            self.user = fetchedUser
            
            self.firstName = fetchedUser.firstName ?? ""
            self.lastName = fetchedUser.lastName ?? ""
            self.emailAddress = fetchedUser.email ?? ""
            self.phoneNumber = fetchedUser.phone ?? ""
            self.dateOfBirth = fetchedUser.dateOfBirth ?? ""
            
            self.streetAddress = fetchedUser.address ?? ""
            self.city = fetchedUser.city ?? ""
            self.state = fetchedUser.state ?? ""
            self.zipCode = fetchedUser.zip ?? ""
        }
    }
    
    func createBirthdatePicker() {
        birthdatePicker.datePickerMode = UIDatePickerMode.date
        
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
        dateOfBirth = dateFormatter.string(from: birthdatePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    ////////////////////////////////////
    //START: THIS NEEDS TO BE CLEANED UP
    ////////////////////////////////////
    
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
    
    ////////////////////////////////////
    //FINISH: THIS NEEDS TO BE CLEANED UP
    ////////////////////////////////////
    
    func saveCells() {
        if let user = user {
            self.view.endEditing(true)
            
            let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Saving")
            
            user.firstName = self.firstName
            user.lastName = self.lastName
            user.email = self.emailAddress
            user.phone = self.phoneNumber
            user.dateOfBirth = self.dateOfBirth
            
            user.address = self.streetAddress
            user.city = self.city
            var state2 = self.state
            state2 = state2?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
            if state2 == "D.C." {
                state2 = "DC"
            }
            
            user.state = state2
            user.zip = self.zipCode
            
            NBUser.editSelf(user) { (result, error) in
                loadingNotification.hide(animated: true)
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                guard let editedUser = result.value else {
                    print("no value was returned")
                    return
                }
                
                UserManager.sharedInstance.user = editedUser
//                self.user = editedUser
                
                self.delegate?.updated(user: editedUser)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}
