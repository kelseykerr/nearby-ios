//
//  TransactionDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/22/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MessageUI

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

class TransactionDetailTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet var exchangeButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var messageUserButton: UIButton!
    
    @IBOutlet var exchangedLabel: UILabel!
    @IBOutlet var returnedLabel: UILabel!
    @IBOutlet var acceptedLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    weak var delegate: TransactionDetailTableViewDelegate?
    var history: NBHistory?
    var mode: TransactionDetailTableViewMode = .none
    
    var exchanged: Bool {
        get {
            return exchangedLabel.text == "yes"
        }
        set {
            exchangedLabel.text = (newValue == true) ? "yes" : "no"
        }
    }
    
    var returned: Bool {
        get {
            return returnedLabel.text == "yes"
        }
        set {
            returnedLabel.text = (newValue == true) ? "yes" : "no"
        }
    }
    
    var accepted: Bool {
        get {
            return acceptedLabel.text == "yes"
        }
        set {
            acceptedLabel.text = (newValue == true) ? "yes" : "no"
        }
    }
    
    var price: String {
        get {
            return priceLabel.text!
        }
        set {
            priceLabel.text = "\(newValue)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        exchangeButton.layer.cornerRadius = exchangeButton.frame.size.height / 16
        exchangeButton.clipsToBounds = true
        
        closeButton.layer.cornerRadius = closeButton.frame.size.height / 16
        closeButton.clipsToBounds = true
        
        messageUserButton.layer.cornerRadius = messageUserButton.frame.size.height / 16
        messageUserButton.layer.borderWidth = 1
        messageUserButton.layer.borderColor = UIColor.nbBlue.cgColor
        messageUserButton.clipsToBounds = true
        
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
            if (history?.request?.status == Status.closed || (transaction.canceled != nil && transaction.canceled!)) {
                self.messageUserButton.isHidden = true
            }
        }
        
    }

    func loadFields(transaction: NBTransaction) {
        exchanged = transaction.exchanged ?? false
        returned = transaction.returned ?? false
        accepted = transaction.sellerAccepted ?? false
        if (transaction.finalPrice != nil) {
            let rawPrice = transaction.finalPrice ?? -9.99
            price = String(format: "$%.2f", rawPrice)
        } else {
            let response = history?.getResponseById(id: (history?.transaction?.responseId)!)
            price = (response?.priceInDollarFormat)!
        }
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
    
    @IBAction func messageUserButtonPressed(_ sender: UIButton) {
        let isBuyer = UserManager.sharedInstance.user?.id == history?.request?.user?.id
        let response = history?.getResponseById(id: (history?.transaction?.responseId)!)
        let phone = isBuyer ? response?.seller?.phone : history?.request?.user?.phone
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
