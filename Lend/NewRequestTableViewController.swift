//
//  NewRequestTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol NewRequestTableViewDelegate: class {
    
    func saved(_ request: NBRequest?)
    
    func cancelled()
    
}

class NewRequestTableViewController: UITableViewController {

    @IBOutlet var itemNameTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var rentImageView: UIImageView!
    @IBOutlet var buyImageView: UIImageView!
    
    weak var delegate: NewRequestTableViewDelegate?
    var request: NBRequest?
    
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
            return !self.rentImageView.isHidden
        }
        set {
            self.rentImageView.isHidden = !newValue
            self.buyImageView.isHidden = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        self.hideKeyboardWhenTappedAround()
        rental = true
        
        if request != nil {
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
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        var req = NBRequest()
        
        if request == nil {
            let currentLocation = LocationManager.sharedInstance.location
            req.latitude = currentLocation?.coordinate.latitude
            req.longitude = currentLocation?.coordinate.longitude
        
            let postDate64: Int64 = Int64(Date().timeIntervalSince1970) * 1000
            req.postDate = postDate64
            
            let oneWeek = 60 * 60 * 24 * 7.0
            let expireDate64: Int64 = Int64(Date().addingTimeInterval(oneWeek).timeIntervalSince1970) * 1000
            req.expireDate = expireDate64
        }
        else {
            req = request?.copy() as! NBRequest
        }
        
        saveFields(request: req)
        
        req.type = "item"
       
        self.delegate?.saved(req)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rentButtonPressed(_ sender: UIButton) {
        rental = true
    }

    @IBAction func buyButtonPressed(_ sender: UIButton) {
        rental = false
    }
    
}
