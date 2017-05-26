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
    
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var pickupLocationText: UITextField!
    @IBOutlet weak var returnLocationText: UITextField!
    @IBOutlet weak var returnTimeDateTextField: UITextField!
    @IBOutlet weak var pickupTimeDateTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
    
    weak var delegate: ResponseDetailTableViewDelegate?
    
    var response: NBResponse?
    var mode: ResponseDetailTableViewMode = .none
    
    let dateFormatter = DateFormatter()
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
        
        createDatePickers()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        switch mode {
        case .buyer:
            descriptionTextView.isEditable = false
            if response?.responseStatus?.rawValue == "CLOSED" {
                priceText.isUserInteractionEnabled = false
                pickupLocationText.isUserInteractionEnabled = false
                returnLocationText.isUserInteractionEnabled = false
                returnTimeDateTextField.isUserInteractionEnabled = false
                pickupTimeDateTextField.isUserInteractionEnabled = false
                acceptButton.isHidden = true
                declineButton.isHidden = true
                navigationItem.rightBarButtonItem = nil
            } else {
                acceptButton.setTitle("Accept/Update", for: UIControlState.normal)
            }
        case .seller:
            if response?.sellerStatus?.rawValue != "ACCEPTED" {
                acceptButton.setTitle("Accept/Update", for: UIControlState.normal)
            } else {
                acceptButton.setTitle("Update", for: UIControlState.normal)
            }
            declineButton.setTitle("Withdraw", for: UIControlState.normal)
            navigationItem.rightBarButtonItem = nil
            //change the color of description to greyish black
        case .none:
            descriptionTextView.isEditable = false
            acceptButton.isHidden = true
            declineButton.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
        
        if let response = response {
            loadFields(response: response)
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 3 && (response?.returnLocation == nil || response?.returnLocation == "") {
            return nil
        }
        else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 && (response?.returnLocation == nil || response?.returnLocation == "") {
            return 0.1
        }
        else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 && (response?.returnLocation == nil || response?.returnLocation == "") {
            return 0.1
        }
        else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 && (response?.returnLocation == nil || response?.returnLocation == "") {
            return 0
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
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
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let flagAction = UIAlertAction(title: "Flag Response", style: .destructive) { action in
            guard let navVC = UIStoryboard.getViewController(identifier: "FlagNavigationController") as? UINavigationController else {
                assert(false, "Misnamed view controller")
                return
            }
            let flagVC = navVC.childViewControllers[0] as! FlagTableViewController
            let requestId = self.response?.requestId ?? "-999"
            let responseId = self.response?.id ?? "-999"
            flagVC.mode = .response(requestId, responseId)
            self.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(flagAction)
        
        if let messageEnabled = response?.messagesEnabled, messageEnabled {
            let messageAction = UIAlertAction(title: "Message User", style: .default) { action in
                if MFMessageComposeViewController.canSendText() {
                    guard let phone = self.response?.seller?.phone else {
                        print("No phone number")
                        return
                    }
                    let controller = MFMessageComposeViewController()
                    controller.recipients = [phone]
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
            }
            alertController.addAction(messageAction)
        }
        
        self.present(alertController, animated: true) {
        }
    }
    
    // is this necessary?
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
