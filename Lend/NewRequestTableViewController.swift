//
//  NewRequestTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol NewRequestTableViewDelegate: class {
    
    func saved(_ request: NBRequest)
    
    func cancelled()
}

class NewRequestTableViewController: UITableViewController {

    @IBOutlet var itemNameTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var buyRentSegmentedControl: UISegmentedControl!

    weak var delegate: NewRequestTableViewDelegate?
    var request: NBRequest?
    
    var itemName: String? {
        get {
            return itemNameTextField.text
        }
    }
    
    var desc: String? {
        get {
            return descriptionTextView.text
        }
    }
    
    var rent: Bool? {
        get {
            return buyRentSegmentedControl.selectedSegmentIndex == 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        print("request saved")
        
        if request == nil {
            let req = NBRequest()
            req.itemName = itemName
            req.desc = desc
            let currentLocation = LocationManager.sharedInstance.location
            req.latitude = currentLocation?.coordinate.latitude
            req.longitude = currentLocation?.coordinate.longitude
            
            print("date in milli")
            print(Date().timeIntervalSince1970)
            
            let postDate64: Int64 = Int64(Date().timeIntervalSince1970) * 1000
            req.postDate = postDate64
            let oneWeek = 60 * 60 * 24 * 7.0
            let expireDate64: Int64 = Int64(Date().addingTimeInterval(oneWeek).timeIntervalSince1970) * 1000
            req.expireDate = expireDate64
            
            req.rental = rent
            
            req.type = "item"

            request = req
        }
        
        //this is wrong.... need to actually set each of the fields here instead of in if statement
        
        delegate?.saved(request!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("request cancelled")
        self.dismiss(animated: true, completion: nil)
        delegate?.cancelled()
    }
}
