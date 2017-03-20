//
//  NewRequestTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol NewRequestTableViewDelegate: class {
    
    func saved(_ request: NBRequest?, error: NSError?)
    
    func edited(_ request: NBRequest?, error: NSError?)
    
    func cancelled()
    
}

class NewRequestTableViewController: UITableViewController {

    @IBOutlet var itemNameTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var buyRentSegmentedControl: UISegmentedControl!

    weak var delegate: NewRequestTableViewDelegate?
    var request: NBRequest?
    var edit = false
    
    var itemName: String? {
        get {
            return itemNameTextField.text
        }
        set {
            itemNameTextField.text = newValue
        }
    }
    
    var desc: String? {
        get {
            return descriptionTextView.text
        }
        set {
            descriptionTextView.text = newValue
        }
    }
    
    var rental: Bool {
        get {
            return buyRentSegmentedControl.selectedSegmentIndex == 1
        }
        set {
            buyRentSegmentedControl.selectedSegmentIndex = newValue ? 1 : 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        if request != nil {
            edit = true
            loadFields(request: request!)
        }
    }
    
    func loadFields(request: NBRequest) {
        itemName = request.itemName
        desc = request.desc
        rental = request.rental!
    }
    
    func saveFields(request: NBRequest) {
        request.itemName = itemName
        request.desc = desc
        request.rental = rental
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if request == nil {
            let req = NBRequest()
            
            let currentLocation = LocationManager.sharedInstance.location
            req.latitude = currentLocation?.coordinate.latitude
            req.longitude = currentLocation?.coordinate.longitude
            
            let postDate64: Int64 = Int64(Date().timeIntervalSince1970) * 1000
            req.postDate = postDate64
            
            let oneWeek = 60 * 60 * 24 * 7.0
            let expireDate64: Int64 = Int64(Date().addingTimeInterval(oneWeek).timeIntervalSince1970) * 1000
            req.expireDate = expireDate64
            
            request = req
        }
        
        saveFields(request: request!)
        
        //tmp
        request?.type = "item"
        
        if edit {
            NBRequest.editRequest(request!) { error in
                self.delegate?.edited(self.request, error: error)
            }
        }
        else {
            NBRequest.addRequest(request!) { error in
                self.delegate?.saved(self.request, error: error)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("request cancelled")
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
}
