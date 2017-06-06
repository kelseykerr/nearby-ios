//
//  EditRequestDetailTableViewController.swift
//  Nearby
//
//  Created by Kerr, Kelsey on 4/13/17.
//  Copyright © 2017 Iuxta, Inc. All rights reserved.
//

import UIKit

protocol EditRequestTableViewDelegate: class {
    
    func edited(_ request: NBRequest?)
    
    func closed(_ request: NBRequest?)
    
}

class EditRequestTableViewController: UITableViewController {
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    weak var delegate: EditRequestTableViewDelegate?
    
    var request: NBRequest?
    var mode: RequestDetailTableViewMode = .none
    
    var itemNameText: String? {
        get {
            return itemName.text
        }
        set {
            itemName.text = newValue
        }
    }
    
    var desc: String? {
        get {
            return descriptionText.text
        }
        set {
            descriptionText.text = newValue
        }
    }
    
    var rent: RequestType {
        get {
            //this can be better, simply make an initializer for enum to do this.... later
            if let rental = rentLabel.text {
                switch rental {
                case "rent":
                    return RequestType.renting
                case "buy":
                    return RequestType.buying
                case "loan":
                    return RequestType.loaning
                case "sell":
                    return RequestType.selling
                default:
                    return RequestType.none
                }
            }
            return RequestType.none
        }
        set {
            rentLabel.text = newValue.rawValue.replacingOccurrences(of: "ing", with: "")
        }
    }
    
    var isMyRequest: Bool {
        get {
            return request?.isMyRequest() ?? false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        closeButton.layer.cornerRadius = closeButton.frame.size.height / 16
        closeButton.clipsToBounds = true
        
        if let request = request {
            loadFields(request: request)
        }
    }
    
    func loadFields(request: NBRequest) {
        itemNameText = request.itemName ?? "<ITEM>"
        desc = request.desc ?? "<DESCRIPTION>"
        rent = request.requestType
    }

    // should we create a new request? or at least make a copy?
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let req = self.request
        req?.itemName = itemNameText
        req?.desc = desc
        self.delegate?.edited(req)
        self.navigationController?.popViewController(animated: true)
    }
    
    // should we create a new request? or at least make a copy?
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        let req = self.request
        let date = Date()
        let calendar = Calendar.current
        calendar.component(.hour, from: date)
        calendar.component(.minute, from: date)
        let dateInt = Int64((date.timeIntervalSince1970 * 1000.0).rounded())
        req?.expireDate = dateInt
        self.delegate?.closed(req)
        self.navigationController?.popViewController(animated: true)
    }
    
}
