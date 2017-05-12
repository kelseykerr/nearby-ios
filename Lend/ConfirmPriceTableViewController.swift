//
//  ConfirmPriceTableViewController.swift
//  Nearby
//
//  Created by Kelsey Kerr on 4/28/17.
//  Copyright © 2017 Iuxta, Inc. All rights reserved.
//

import UIKit

protocol ConfirmPriceTableViewDelegate: class {
    
    func confirmed(_ transaction: NBTransaction?)
    
}

class ConfirmPriceTableViewController:  UITableViewController {
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var priceField: UITextField!
    
    weak var delegate: ConfirmPriceTableViewDelegate?

    
    var history: NBHistory?

    var price: Float? {
        get {
            let priceString = priceField.text
            return Float(priceString!)
        }
        set {
            let price = newValue ?? -9.99
            priceField.text = String(format: "%.2f", price)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let type = (history?.request?.rental)! ? "loaning" : "selling"
        let item = history?.request?.itemName! ?? "item"
        let buyer = history?.request?.user?.firstName! ?? "the buyer"
        let message = "Confirm the price for \(type) your \(item) to \(buyer)"
        return message
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.layer.cornerRadius = confirmButton.frame.size.height / 16
        confirmButton.clipsToBounds = true
        
        if let transaction = history?.transaction {
            loadFields(transaction: transaction)
        }
    }
    
    func loadFields(transaction: NBTransaction) {
        if (transaction.finalPrice != nil) {
            price = transaction.finalPrice!
        } else {
            let response = history?.getResponseById(id: (history?.transaction?.responseId)!)
            price = (response?.offerPrice)!
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        let response = history?.getResponseById(id: (history?.transaction?.responseId)!)
        let offerPrice = response?.offerPrice
        if (price == nil || price! > offerPrice!) {
            showError()
            return
        } else {
            history?.transaction?.priceOverride = price
            delegate?.confirmed(history?.transaction)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showError() {
        let response = history?.getResponseById(id: (history?.transaction?.responseId)!)
        let originalOffer = response?.priceInDollarFormat
        let alert = UIAlertController(title: "Invalid Input", message: "You must enter a valid price no greater than \(originalOffer ?? "$0.00")", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: { action in
            switch action.style {
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
