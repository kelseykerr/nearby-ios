//
//  ResponseDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/12/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

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

class ResponseDetailTableViewController: UITableViewController {
    
    @IBOutlet var priceText: UITextField!
    @IBOutlet var pickupLocationText: UITextField!
    @IBOutlet var returnLocationText: UITextField!
    @IBOutlet var returnTimeDateTextField: UITextField!
    @IBOutlet var pickupTimeDateTextField: UITextField!
    
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var declineButton: UIButton!
    
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
            let price = newValue ?? -9.99
            priceText.text = String(format: "%.2f", price)
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
            let date = dateFormatter.date(from: dateString!)
            return Int64((date?.timeIntervalSince1970)!) * 1000
        }
        set {
            //move to Utils
            let epoch = (newValue ?? 0) / 1000
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
            let date = dateFormatter.date(from: dateString!)
            return Int64((date?.timeIntervalSince1970)!) * 1000
        }
        set {
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
        
        acceptButton.layer.cornerRadius = acceptButton.frame.size.height / 16
        acceptButton.clipsToBounds = true
        
        declineButton.layer.cornerRadius = declineButton.frame.size.height / 16
        declineButton.clipsToBounds = true
        
        createDatePickers()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let response = response {
            loadFields(response: response)

            if mode == .seller {
                self.acceptButton.setTitle("Update", for: UIControlState.normal)
                self.declineButton.setTitle("Withdraw", for: UIControlState.normal)
            }
            if mode == .buyer {
                if (response.responseStatus?.rawValue == "CLOSED") {
                    self.acceptButton.isHidden = true
                    self.declineButton.isHidden = true
                } else {
                    self.acceptButton.setTitle("Accept/Update", for: UIControlState.normal)
                }
            }
            else if mode == .none {
                self.acceptButton.isHidden = true
                self.declineButton.isHidden = true
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
    
}

extension ResponseDetailTableViewController: NewResponseTableViewDelegate {
    
    func saved(_ response: NBResponse?) {
        delegate?.edited(response)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelled() {
    }
    
}
