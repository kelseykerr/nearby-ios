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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        createDropDowns()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        loadCells()
    }
    
    func loadCells() {
        UserManager.sharedInstance.getUser { fetchedUser in
            self.user = fetchedUser
            
            self.requestNotificationEnabledSwitch.isOn = fetchedUser.newRequestNotificationsEnabled ?? false
            self.currentLocationSwitch.isOn = fetchedUser.currentLocationNotifications ?? false
            self.homeLocationSwitch.isOn = fetchedUser.homeLocationNotifications ?? false
            self.radiusButton.setTitle(String(format: "%.1f", fetchedUser.notificationRadius ?? 0.0), for: UIControlState.normal)
        }
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
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCells()
    }
    
    @IBAction func radiusButtonPressed(_ sender: UIButton) {
        dropDown.show()
    }
    
    func saveCells() {
        if user != nil {
            user?.newRequestNotificationsEnabled = self.requestNotificationEnabledSwitch.isOn
            user?.homeLocationNotifications = self.homeLocationSwitch.isOn
            user?.currentLocationNotifications = self.currentLocationSwitch.isOn
//            user?.notificationRadius = Float(self.radiusTextField.text!) ?? 0.0
            user?.notificationRadius = Float(self.radiusButton.title(for: UIControlState.normal)!) ?? 0.0
            
            self.view.endEditing(true)
            
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Saving"
            
            NBUser.editSelf(user!) { (result, error) in
                loadingNotification.hide(animated: true)
                
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
