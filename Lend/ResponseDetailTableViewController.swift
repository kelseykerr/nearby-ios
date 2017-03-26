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
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceTypeLabel: UILabel!
    @IBOutlet var pickupLocationLabel: UILabel!
    @IBOutlet var pickupTimeLabel: UILabel!
    @IBOutlet var returnLocationLabel: UILabel!
    @IBOutlet var returnTimeLabel: UILabel!
    
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var declineButton: UIButton!
    
    let dateFormatter = DateFormatter()
    
    weak var delegate: ResponseDetailTableViewDelegate?
    var response: NBResponse?
    var mode: ResponseDetailTableViewMode = .none

    var price: Float? {
        get {
            let priceString = priceLabel.text
            return Float(priceString!)
        }
        set {
            let price = newValue ?? -9.99
            priceLabel.text = String(format: "%.2f", price)
        }
    }
    
    var pickupLocation: String? {
        get {
            return pickupLocationLabel.text
        }
        set {
            pickupLocationLabel.text = newValue
        }
    }
    
    var pickupTime: Int64? {
        get {
            //move to Utils
            let dateString = pickupTimeLabel.text
            let date = dateFormatter.date(from: dateString!)
            return Int64((date?.timeIntervalSince1970)!) * 1000
        }
        set {
            //move to Utils
            let epoch = (newValue ?? 0) / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(epoch))
            let dateString = dateFormatter.string(from: date)
            pickupTimeLabel.text = dateString
        }
    }
    
    var returnLocation: String? {
        get {
            return returnLocationLabel.text
        }
        set {
            returnLocationLabel.text = newValue
        }
    }
    
    var returnTime: Int64? {
        get {
            let dateString = returnTimeLabel.text
            let date = dateFormatter.date(from: dateString!)
            return Int64((date?.timeIntervalSince1970)!) * 1000
        }
        set {
            let epoch = (newValue ?? 0) / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(epoch))
            let dateString = dateFormatter.string(from: date)
            returnTimeLabel.text = dateString
        }
    }
    
    var priceType: PriceType {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptButton.layer.cornerRadius = acceptButton.frame.size.height / 16
        acceptButton.clipsToBounds = true
        
        declineButton.layer.cornerRadius = declineButton.frame.size.height / 16
        declineButton.clipsToBounds = true
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let response = response {
            loadFields(response: response)

            if mode == .seller {
                self.acceptButton.setTitle("Withdraw", for: UIControlState.normal)
                self.acceptButton.backgroundColor = UIColor.nbRed
                
                self.declineButton.isHidden = true
            }
            else if mode == .none {
                self.acceptButton.isHidden = true
                self.declineButton.isHidden = true
            }
        }
    }
    
    func loadFields(response: NBResponse) {
        price = response.offerPrice
        priceType = response.priceType!
        pickupLocation = response.exchangeLocation
        pickupTime = response.exchangeTime
        returnLocation = response.returnLocation
        returnTime = response.returnTime
    }

    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        if mode == .buyer {
            print("accept button pressed")
            
            delegate?.accepted(response)
            self.navigationController?.popViewController(animated: true)
        }
        else {
            print("withdraw button pressed")
            
            delegate?.withdrawn(response)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func declineButtonPressed(_ sender: UIButton) {
        print("accept button pressed")
        
        delegate?.declined(response)
        self.navigationController?.popViewController(animated: true)
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
