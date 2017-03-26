//
//  TransactionDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/22/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol TransactionDetailTableViewDelegate: class {
    
    func closed(_ request: NBRequest?)
    
    func confirmed(_ transaction: NBTransaction?)
    
    func next()
    
    func scanned(transId: String, code: String)
    
}

enum TransactionDetailTableViewMode {
    case buyer_generate
    case buyer_scan
    case seller_generate
    case seller_scan
    case confirm
    case none
}

class TransactionDetailTableViewController: UITableViewController {

    @IBOutlet var exchangeButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    
    @IBOutlet var exchangedLabel: UILabel!
    @IBOutlet var returnedLabel: UILabel!
    @IBOutlet var acceptedLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    weak var delegate: TransactionDetailTableViewDelegate?
    var history: NBHistory?
    var mode: TransactionDetailTableViewMode = .none
    
    var exchanged: Bool {
        get {
            return exchangedLabel.text == "true"
        }
        set {
            exchangedLabel.text = (newValue == true) ? "true" : "false"
        }
    }
    
    var returned: Bool {
        get {
            return returnedLabel.text == "true"
        }
        set {
            returnedLabel.text = (newValue == true) ? "true" : "false"
        }
    }
    
    var accepted: Bool {
        get {
            return acceptedLabel.text == "true"
        }
        set {
            acceptedLabel.text = (newValue == true) ? "true" : "false"
        }
    }
    
    var price: Float {
        get {
            return Float(priceLabel.text!)!
        }
        set {
            if newValue >= 0 {
                priceLabel.text = "\(newValue)"
            }
            else {
                priceLabel.text = "no price"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        exchangeButton.layer.cornerRadius = exchangeButton.frame.size.height / 16
        exchangeButton.clipsToBounds = true
        
        closeButton.layer.cornerRadius = closeButton.frame.size.height / 16
        closeButton.clipsToBounds = true
        
        if let transaction = history?.transaction {
            loadFields(transaction: transaction)
            
            if mode == .confirm {
                self.exchangeButton.setTitle("Price Confirm", for: UIControlState.normal)
                self.closeButton.isHidden = true
            }
            else if mode == .seller_generate || mode == .seller_scan {
                self.closeButton.isHidden = true
            }
            else if mode == .none {
                self.closeButton.isHidden = true
                self.exchangeButton.isHidden = true
            }
        }
        
    }

    func loadFields(transaction: NBTransaction) {
        exchanged = transaction.exchanged ?? false
        returned = transaction.returned ?? false
        accepted = transaction.sellerAccepted ?? false
        price = transaction.finalPrice ?? -9.99
    }

    @IBAction func exchangeButtonPressed(_ sender: UIButton) {
    
        if mode == .buyer_scan || mode == .seller_scan {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRScannerNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let scannerVC = (navVC.childViewControllers[0] as! QRScannerViewController)
            scannerVC.delegate = self
            scannerVC.transaction = self.history?.transaction
            self.present(navVC, animated: true, completion: nil)
        }
        else if mode == .buyer_generate || mode == .seller_generate {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRGeneratorNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let generatorVC = (navVC.childViewControllers[0] as! QRGeneratorViewController)
            generatorVC.delegate = self
            generatorVC.transaction = self.history?.transaction
            self.present(navVC, animated: true, completion: nil)
        }
        else if mode == .confirm {
            // maybe popup?
            delegate?.confirmed(history?.transaction)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        // should I send transaction or request
//        delegate.closed()
    }
    
}

extension TransactionDetailTableViewController: QRGeneratorViewDelegate, QRScannerViewDelegate {
    
    func next() {
        print("Next pressed")
        delegate?.next()
        self.navigationController?.popViewController(animated: true)
    }
    
    func generateCancelled() {
        print("generate cancelled")
    }

    func scanned(transId: String, code: String) {
        print("scanned")
        delegate?.scanned(transId: transId, code: code)
        self.navigationController?.popViewController(animated: true)
    }
    
    func scanCancelled() {
        print("scan cancelled")
    }
    
}
