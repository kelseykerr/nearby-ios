//
//  NewResponseTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/7/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol NewResponseTableViewDelegate: class {
    
    func saved(_ response: NBResponse)
    
    func cancelled()
    
}

class NewResponseTableViewController: UITableViewController {

    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var pickupLocationTextField: UITextField!
    @IBOutlet var pickupTimeDatePicker: UIDatePicker!
    @IBOutlet var returnLocationTextField: UITextField!
    @IBOutlet var returnTimeDatePicker: UIDatePicker!

    weak var delegate: NewResponseTableViewDelegate?
    var response: NBResponse?
    
    var price: Float? {
        get {
            let priceString = priceTextField.text
            return Float(priceString!)
        }
        set {
            priceTextField.text = "\(newValue)"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if response != nil {
            loadFields(response: response!)
        }
    }
    
    func loadFields(response: NBResponse) {
        price = response.offerPrice
        pickupLocation = response.exchangeLocation
        returnLocation = response.returnLocation
    }
    
    func saveFields(response: NBResponse) {
        response.offerPrice = price
        response.exchangeLocation = pickupLocation
        response.returnLocation = returnLocation
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("response cancelled")
        self.dismiss(animated: true, completion: nil)
        delegate?.cancelled()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        print("response saved")

        if response == nil {
            let resp = NBResponse(test: true)
            response = resp
        }
        
        saveFields(response: response!)
        
        response?.offerPrice = 1.23
        response?.requestId = "5879914946e0fb0001ac31e1"
//        response?.sellerId = "190639591352732"
        response?.sellerId = "57cb219dc9e77c00012edac3"
        response?.exchangeLocation = "My house."
//        response?.exchangeTime = 1482545760000
        response?.returnLocation = "Your house."
//        response?.returnTime = 1582545770000
        response?.priceType = "FLAT"
        
        NBResponse.addResponse(response!) { error in
            if let error = error {
                print("There was an error")
            }
        }
        
        delegate?.saved(response!)
        self.dismiss(animated: true, completion: nil)
    }
}
