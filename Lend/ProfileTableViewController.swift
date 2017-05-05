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
    
    @IBOutlet var requestNotificationEnabledSwitch: UISwitch!
    @IBOutlet var currentLocationSwitch: UISwitch!
    @IBOutlet var homeLocationSwitch: UISwitch!
    @IBOutlet var radiusTextField: UITextField!
    @IBOutlet var radiusButton: UIButton!
    
    @IBOutlet var saveButton: UIButton!
    
    var user: NBUser?
    
    let dropDown = DropDown()
    
    let birthdatePicker = UIDatePicker()
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        createDatePickers()
        createDropDowns()
        
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
            
            self.requestNotificationEnabledSwitch.isOn = fetchedUser.newRequestNotificationsEnabled ?? false
            self.currentLocationSwitch.isOn = fetchedUser.currentLocationNotifications ?? false
            self.homeLocationSwitch.isOn = fetchedUser.homeLocationNotifications ?? false
//            self.radiusTextField.text = String(format: "%.1f", fetchedUser.notificationRadius ?? 0.0)
            self.radiusButton.setTitle(String(format: "%.1f", fetchedUser.notificationRadius ?? 0.0), for: UIControlState.normal)
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
    
    func createDropDowns() {
        dropDown.anchorView = radiusButton
        dropDown.dataSource = ["0.1", "0.25", "0.5", "1.0", "5.0", "10.0"]
        dropDown.bottomOffset = CGPoint(x: 0, y: radiusButton.bounds.height)
        
        self.radiusButton.setTitle("10.0", for: UIControlState.normal)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDown.hide()
            self.radiusButton.setTitle(item, for: UIControlState.normal)
        }
    }
    
    func birthdateDoneButtonPressed() {
        dateOfBirthTextField.text = dateFormatter.string(from: birthdatePicker.date)
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    @IBAction func radiusButtonPressed(_ sender: UIButton) {
        dropDown.show()
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
            
            user?.newRequestNotificationsEnabled = self.requestNotificationEnabledSwitch.isOn
            user?.homeLocationNotifications = self.homeLocationSwitch.isOn
            user?.currentLocationNotifications = self.currentLocationSwitch.isOn
//            user?.notificationRadius = Float(self.radiusTextField.text!) ?? 0.0
            user?.notificationRadius = Float(self.radiusButton.title(for: UIControlState.normal)!) ?? 0.0
            
            self.view.endEditing(true)
            
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Saving"
            
            NBUser.editSelf(user!) { result in
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                guard result.error == nil else {
                    let alert = Utils.createServerErrorAlert(error: result.error as! NSError)
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
