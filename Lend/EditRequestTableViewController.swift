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
    
    @IBOutlet var itemName: UITextField!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var saveButton: UIButton!
    
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
    
    var isMyRequest: Bool {
        get {
            return request?.isMyRequest() ?? false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        if let request = request {
            loadFields(request: request)
        }
    }
    
    func loadFields(request: NBRequest) {
        itemNameText = request.itemName
        desc = request.desc
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let req = self.request
        req?.itemName = self.itemName.text
        req?.desc = self.descriptionText.text
        self.delegate?.edited(req)
        self.navigationController?.popViewController(animated: true)

        //self.dismiss(animated: true, completion: nil)
    }

    
}
