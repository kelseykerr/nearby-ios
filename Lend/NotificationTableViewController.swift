//
//  NotificationTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 11/12/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MBProgressHUD
import DropDown


class NotificationTableViewController: UITableViewController {
    
    @IBOutlet var requestNotificationEnabledSwitch: UISwitch!
    @IBOutlet var currentLocationSwitch: UISwitch!
    @IBOutlet var homeLocationSwitch: UISwitch!
    @IBOutlet var radiusButton: UIButton!
    
    @IBOutlet var saveButton: UIButton!
    
    var user: NBUser?
    
    let dropDown = DropDown()
    
    var requestNotificationEnabled: Bool {
        get {
            return requestNotificationEnabledSwitch.isOn
        }
        set {
            requestNotificationEnabledSwitch.isOn = newValue
        }
    }
    
    var currentLocation: Bool {
        get {
            return currentLocationSwitch.isOn
        }
        set {
            currentLocationSwitch.isOn = newValue
        }
    }
    
    var homeLocation: Bool {
        get {
            return homeLocationSwitch.isOn
        }
        set {
            homeLocationSwitch.isOn = newValue
        }
    }
    
    var radius: Float {
        get {
            return Float(self.radiusButton.title(for: UIControlState.normal) ?? "0.0") ?? 0.0
        }
        set {
            self.radiusButton.setTitle(String(format: "%.1f", newValue), for: UIControlState.normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        createDropDowns()
        
        saveButton.layer.cornerRadius = 4
        saveButton.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        saveButton.layer.borderWidth = 1.0
        saveButton.clipsToBounds = true
        
        loadCells()
    }
    
    func loadCells() {
        UserManager.sharedInstance.getUser { fetchedUser in
            self.user = fetchedUser
            
            self.requestNotificationEnabled = fetchedUser.newRequestNotificationsEnabled ?? false
            self.currentLocation = fetchedUser.currentLocationNotifications ?? false
            self.homeLocation = fetchedUser.homeLocationNotifications ?? false
            self.radius = fetchedUser.notificationRadius ?? 0.0
        }
    }
    
    func createDropDowns() {
        dropDown.anchorView = radiusButton
        dropDown.dataSource = ["0.1", "0.25", "0.5", "1.0", "5.0", "10.0"]
        dropDown.bottomOffset = CGPoint(x: 0, y: radiusButton.bounds.height)
        
        self.radiusButton.setTitle("10.0", for: UIControlState.normal)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            print("Selected item: \(item) at index: \(index)")
            self.dropDown.hide()
            self.radiusButton.setTitle(item, for: UIControlState.normal)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    @IBAction func radiusButtonPressed(_ sender: UIButton) {
        dropDown.show()
    }
    
    func saveCells() {
        guard let user = user else {
            print("not a valid user")
            return
        }
        
        self.view.endEditing(true)
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Saving"
        
        user.newRequestNotificationsEnabled = requestNotificationEnabled
        user.homeLocationNotifications = homeLocation
        user.currentLocationNotifications = currentLocation
        user.notificationRadius = radius
        
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
            self.user = editedUser
        }
        
    }
    
}
