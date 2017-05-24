//
//  NewResponseTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/7/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol NewResponseTableViewDelegate: class {
    
    func saved(_ response: NBResponse?)
    
    func cancelled()
    
}

class NewResponseTableViewController: UITableViewController {

    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var pickupLocationTextField: UITextField!
    @IBOutlet var pickupTimeDatePicker: UIDatePicker!
    @IBOutlet var pickupTimeDateTextField: UITextField!
    @IBOutlet var returnLocationTextField: UITextField!
    @IBOutlet var returnTimeDatePicker: UIDatePicker!
    @IBOutlet var returnTimeDateTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var messagesEnabledSwitch: UISwitch!

    /*@IBOutlet var perHourImageView: UIImageView!
    @IBOutlet var perDayImageView: UIImageView!
    @IBOutlet var flatImageView: UIImageView!*/
    
    @IBOutlet var saveButton: UIButton!
    
    weak var delegate: NewResponseTableViewDelegate?
    var request: NBRequest?
    var response: NBResponse?
    
    let pickupDatePicker = UIDatePicker()
    let returnDatePicker = UIDatePicker()
    
    let dateFormatter = DateFormatter()
    
    var price: Float? {
        get {
            let priceString = priceTextField.text
            return Float(priceString!)
        }
        set {
            priceTextField.text = "\(newValue)"
        }
    }
    
    var responseDescription: String? {
        get {
            return descriptionTextView.text
        }
        set {
            descriptionTextView.text = newValue
        }
    }
    
    var pickupLocation: String? {
        get {
            return pickupLocationTextField.text
        }
        set {
            pickupLocationTextField.text = newValue
        }
    }
    
    
//    var pickupTime: String? {
//        get {
//            return pickupTimeDatePicker
//        }
//    }
    
    var returnLocation: String? {
        get {
            return returnLocationTextField.text
        }
        set {
            returnLocationTextField.text = newValue
        }
    }
    
//    var returnTime: String? {
//        get {
//            return returnTimeDatePicker
//        }
//    }
    
    var priceType: PriceType {
        get {
            /*if !self.perHourImageView.isHidden {
                return .per_hour
            }
            else if !self.perDayImageView.isHidden {
                return .per_day
            }
            else {
                return .flat
            }*/
            return .flat
        }
        set {
            /*self.perHourImageView.isHidden = (newValue != .per_hour)
            self.perDayImageView.isHidden = (newValue != .per_day)
            self.flatImageView.isHidden = (newValue != .flat)*/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
//        priceType = .per_hour
        priceType = .flat
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        createDatePickers()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if response != nil {
            loadFields(response: response!)
        }
    }
    
    func createDatePickers() {
        let pickupToolbar = UIToolbar()
        pickupToolbar.sizeToFit()
        
        let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let pickupDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(pickupDoneButtonPressed))
        pickupToolbar.setItems([spaceBarItem, pickupDoneButton], animated: false)
        
        pickupTimeDateTextField.inputAccessoryView = pickupToolbar
        pickupTimeDateTextField.inputView = pickupDatePicker
        
        let returnToolbar = UIToolbar()
        returnToolbar.sizeToFit()
        
        let returnDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(returnDoneButtonPressed))
        returnToolbar.setItems([spaceBarItem, returnDoneButton], animated: false)
        
        returnTimeDateTextField.inputAccessoryView = returnToolbar
        returnTimeDateTextField.inputView = returnDatePicker
    }
    
    func pickupDoneButtonPressed() {
        pickupTimeDateTextField.text = dateFormatter.string(from: pickupDatePicker.date)
        self.view.endEditing(true)
    }
    
    func returnDoneButtonPressed() {
        returnTimeDateTextField.text = dateFormatter.string(from: returnDatePicker.date)
        self.view.endEditing(true)
        
    }
    
    func loadFields(response: NBResponse) {
        price = response.offerPrice
        pickupLocation = response.exchangeLocation
        returnLocation = response.returnLocation
        responseDescription = response.description
    }
    
    func saveFields(response: NBResponse) {
        response.offerPrice = price
        response.exchangeLocation = pickupLocation
        response.returnLocation = returnLocation
        response.description = responseDescription
    }
    
    //magic numbers are bad
    //really should be checking rental againt some enum? and maybe check if nil in the model itself
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 3 && !(request?.rental)! {
            return nil
        }
        else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 && !(request?.rental)! {
            return 0.1
        }
        else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 && !(request?.rental)! {
            return 0.1
        }
        else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 && !(request?.rental)! {
            return 0
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("response cancelled")
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("response saved")

        if response == nil {
            let resp = NBResponse(test: true)
            response = resp
        }
        
        saveFields(response: response!)
        
        response?.offerPrice = price
        response?.description = responseDescription
        response?.requestId = request?.id
        response?.sellerId = UserManager.sharedInstance.user?.userId
        response?.exchangeLocation = pickupLocation
        //do not set a default pickup time - leave it empty if the user didn't enter anything
        if (!(pickupTimeDateTextField.text ?? "").isEmpty) {
            response?.exchangeTime = Int64(pickupDatePicker.date.timeIntervalSince1970) * 1000
        }
        response?.returnLocation = returnLocation
        //do not set a default return time - leave it empty if the user didn't enter anything
        if (!(returnTimeDateTextField.text ?? "").isEmpty) {
            response?.returnTime = Int64(returnDatePicker.date.timeIntervalSince1970) * 1000
        }
        response?.messagesEnabled = messagesEnabledSwitch.isOn
//        response?.priceType = priceType
        response?.priceType = .flat
        
        delegate?.saved(response)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func perHourButtonPressed(_ sender: UIButton) {
//        priceType = .per_hour
    }
    
    @IBAction func perDayButtonPressed(_ sender: UIButton) {
//        priceType = .per_day
    }
    
    @IBAction func flatButtonPressed(_ sender: UIButton) {
        priceType = .flat
    }
    
}
