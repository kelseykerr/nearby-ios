//
//  ResponseDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/12/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import MessageUI

protocol ResponseDetailTableViewDelegate: class {
    
    //response
    
    func edited(_ response: NBResponse?)
    
    func withdrawn(_ response: NBResponse?)
    
    func accepted(_ response: NBResponse?)
    
    func declined(_ response: NBResponse?)
    
}

enum ResponseDetailTableViewMode {
    case buyer
    case seller
    case none
}

class ResponseDetailTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet var priceText: UITextField!
    @IBOutlet var pickupLocationText: UITextField!
    @IBOutlet var returnLocationText: UITextField!
    @IBOutlet var returnTimeDateTextField: UITextField!
    @IBOutlet var pickupTimeDateTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!

    
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var declineButton: UIButton!
    @IBOutlet var messageUserButton: UIButton!
    
    let dateFormatter = DateFormatter()
    
    weak var delegate: ResponseDetailTableViewDelegate?
    var response: NBResponse?
    var mode: ResponseDetailTableViewMode = .none
    
    let pickupDatePicker = UIDatePicker()
    let returnDatePicker = UIDatePicker()
    
    var price: Float? {
        get {
            let priceString = priceText.text
            return Float(priceString!)
        }
        set {
            let price = newValue ?? 0
            priceText.text = String(format: "%.2f", price)
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
            return pickupLocationText.text
        }
        set {
            pickupLocationText.text = newValue
        }
    }
    
    var pickupTime: Int64? {
        get {
            //move to Utils
            let dateString = pickupTimeDateTextField.text
            if (dateString == nil || dateString == "") {
                return nil
            }
            let date = dateFormatter.date(from: dateString!)
            return Int64((date?.timeIntervalSince1970)!) * 1000
        }
        set {
            //move to Utils
            if (newValue == nil) {
                pickupTimeDateTextField.text = ""
                return
            }
            let epoch = (newValue)! / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(epoch))
            let dateString = dateFormatter.string(from: date)
            pickupTimeDateTextField.text = dateString
        }
    }
    
    var returnLocation: String? {
        get {
            return returnLocationText.text
        }
        set {
            returnLocationText.text = newValue
        }
    }
    
    var returnTime: Int64? {
        get {
            let dateString = returnTimeDateTextField.text
            if (dateString == nil || dateString == "") {
                return nil
            }
            let date = dateFormatter.date(from: dateString!)
            return Int64((date?.timeIntervalSince1970)!) * 1000
        }
        set {
            if (newValue == nil) {
                returnTimeDateTextField.text = ""
                return
            }
            let epoch = (newValue ?? 0) / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(epoch))
            let dateString = dateFormatter.string(from: date)
            returnTimeDateTextField.text = dateString
        }
    }
    
    /*var priceType: PriceType {
        get {
            let priceTypeString = priceTypeLabel.text!
            switch priceTypeString {
            case PriceType.per_hour.rawValue:
                return .per_hour
            case PriceType.per_day.rawValue:
                return .per_day
            case PriceType.flat.rawValue:
                return .flat
            default: // this is bad, fix it
                return .flat
            }
        }
        set {
            switch newValue {
            case PriceType.per_hour:
                priceTypeLabel.text = PriceType.per_hour.rawValue
            case PriceType.per_day:
                priceTypeLabel.text = PriceType.per_day.rawValue
            case PriceType.flat:
                priceTypeLabel.text = PriceType.flat.rawValue
            }
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        acceptButton.layer.cornerRadius = acceptButton.frame.size.height / 16
        acceptButton.clipsToBounds = true
        
        declineButton.layer.cornerRadius = declineButton.frame.size.height / 16
        declineButton.clipsToBounds = true
        
        messageUserButton.layer.cornerRadius = messageUserButton.frame.size.height / 16
        messageUserButton.layer.borderWidth = 1
        messageUserButton.layer.borderColor = UIColor.nbBlue.cgColor
        messageUserButton.clipsToBounds = true
        
        createDatePickers()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let response = response {
            loadFields(response: response)

            if mode == .seller {
                self.messageUserButton.isHidden = true
                if (response.sellerStatus?.rawValue != "ACCEPTED") {
                    self.acceptButton.setTitle("Accept/Update", for: UIControlState.normal)
                } else {
                    self.acceptButton.setTitle("Update", for: UIControlState.normal)
                }
                self.declineButton.setTitle("Withdraw", for: UIControlState.normal)
            }
            if mode == .buyer {
                descriptionTextView.isEditable = false
                if (response.responseStatus?.rawValue == "CLOSED") {
                    priceText.isUserInteractionEnabled = false
                    pickupLocationText.isUserInteractionEnabled = false
                    returnLocationText.isUserInteractionEnabled = false
                    returnTimeDateTextField.isUserInteractionEnabled = false
                    pickupTimeDateTextField.isUserInteractionEnabled = false
                    
                    self.acceptButton.isHidden = true
                    self.declineButton.isHidden = true
                    self.messageUserButton.isHidden = true
                } else {
                    self.acceptButton.setTitle("Accept/Update", for: UIControlState.normal)
                }
                if (response.messagesEnabled == nil || !response.messagesEnabled!) {
                    self.messageUserButton.isHidden = true
                }
            }
            else if mode == .none {
                descriptionTextView.isEditable = false
                self.acceptButton.isHidden = true
                self.declineButton.isHidden = true
                self.messageUserButton.isHidden = true
            }
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
        if (response?.exchangeTime != nil && response?.exchangeTime != 0) {
            let epoch = (response?.exchangeTime ?? 0) / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(epoch))
            pickupDatePicker.setDate(date, animated: true)
        }
        
        let returnToolbar = UIToolbar()
        returnToolbar.sizeToFit()
        
        let returnDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(returnDoneButtonPressed))
        returnToolbar.setItems([spaceBarItem, returnDoneButton], animated: false)
        
        returnTimeDateTextField.inputAccessoryView = returnToolbar
        returnTimeDateTextField.inputView = returnDatePicker
        if (response?.returnTime != nil && response?.returnTime != 0) {
            let epoch = (response?.returnTime ?? 0) / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(epoch))
            returnDatePicker.setDate(date, animated: false)
        }
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
        pickupTime = response.exchangeTime
        returnLocation = response.returnLocation
        returnTime = response.returnTime
        responseDescription = response.description
    }

    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        response?.offerPrice = price
        response?.exchangeLocation = pickupLocation
        response?.exchangeTime = pickupTime
        response?.returnLocation = returnLocation
        response?.returnTime = returnTime
        if mode == .buyer {
            print("accept button pressed")
            delegate?.accepted(response)
            self.navigationController?.popViewController(animated: true)
        } else {
            print("update button pressed")
            response?.description = responseDescription
            response?.sellerStatus = SellerStatus.accepted
            delegate?.edited(response)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func declineButtonPressed(_ sender: UIButton) {
        if mode == .seller {
            print("withdraw button pressed")
            delegate?.withdrawn(response)
            self.navigationController?.popViewController(animated: true)
        } else {
            print("accept button pressed")
            
            delegate?.declined(response)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func messageUserButtonPressed(_ sender: UIButton) {
        let phone = response?.seller?.phone
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.recipients = [phone!]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

extension ResponseDetailTableViewController: NewResponseTableViewDelegate {
    
    func saved(_ response: NBResponse?) {
        delegate?.edited(response)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelled() {
    }
    
}
