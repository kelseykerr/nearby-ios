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
    @IBOutlet var dateOfBirthTextField: UITextField!
    
    @IBOutlet var streetAddressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var zipCodeTextField: UITextField!
    
    var user: NBUser?
    
    let progressHUD = ProgressHUD(text: "Saving")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.view.addSubview(progressHUD)
        progressHUD.hide()
        
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
//        if user != nil {
//            self.firstNameTextField.text = user?.firstName ?? ""
//            self.lastNameTextField.text = user?.lastName ?? ""
//            self.emailAddressTextField.text = user?.email ?? ""
//            self.phoneNumberTextField.text = user?.phone ?? ""
//            self.dateOfBirthTextField.text = user?.dateOfBirth ?? ""
//            
//            self.streetAddressTextField.text = user?.address ?? ""
//            self.cityTextField.text = user?.city ?? ""
//            self.stateTextField.text = user?.state ?? ""
//            self.zipCodeTextField.text = user?.zip ?? ""
//        }
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
            user?.dateOfBirth = self.dateOfBirthTextField.text
            
            user?.address = self.streetAddressTextField.text
            user?.city = self.cityTextField.text
            user?.state = self.stateTextField.text
            user?.zip = self.zipCodeTextField.text
            
            //tmp
            user?.tosAccepted = true
            user?.tosAcceptIp = "0.0.0.0"
            
            print(user?.toString())
            
            progressHUD.show()
            
            UserManager.sharedInstance.editUser(user: user!, completionHandler: { error in
                self.progressHUD.hide()
                
                if (error != nil) {
                    print("there was an error")
                }
                else {
                    print("no error")
                }
            })
            
//            NBUser.editSelf(user!, completionHandler: { error in
//                if (error != nil) {
//                    print("there was an error")
//                }
//                else {
//                    print("no error")
//                }
//            })
        }
    }

}
