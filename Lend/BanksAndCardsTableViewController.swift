//
//  BanksAndCardsTableViewController.swift
//  Nearby
//
//  Created by Kerr, Kelsey on 4/9/17.
//  Copyright © 2017 Iuxta Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class BanksAndCardsTableViewController: UITableViewController {
    var user: NBUser?
    var paymentInfo: NBPayment?
    
    @IBOutlet weak var accountNumber: UILabel!
    @IBOutlet weak var routingNumber: UILabel!

    @IBOutlet weak var creditCardNumber: UILabel!
    @IBOutlet weak var ccExp: UILabel!
    
    var alertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPaymentInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BanksAndCardsToPaymentSegue" {
            let paymentTableViewController = segue.destination as! PaymentTableViewController
            paymentTableViewController.delegate = self
        }
        if segue.identifier == "BanksAndCardsToBankSegue" {
            let directDepositTableViewController = segue.destination as! DirectDepositTableViewController
            directDepositTableViewController.delegate = self
        }
    }

    func loadPaymentInfo() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Fetching..."
        
        NBPayment.fetchPaymentInfo { (result, error) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let paymentInfo = result.value else {
                print("no payment info fetched")
                return
            }
            
            self.paymentInfo = paymentInfo
            
            if let accountNumber = self.paymentInfo?.bankAccountLast4, let routingNumber = self.paymentInfo?.routingNumber {
                self.accountNumber.text = accountNumber
                self.routingNumber.text = routingNumber
            }
            
            if let creditCardNumber = self.paymentInfo?.ccMaskedNumber, let ccExp = self.paymentInfo?.ccExpDate {
                self.creditCardNumber.text = creditCardNumber
                self.ccExp.text = ccExp
            }
            
            self.tableView.reloadData()
        }
    }

}

extension BanksAndCardsTableViewController: UpdatePaymentInfoDelegate, UpdateBankInfoDelegate {
    
    func refreshStripeInfo() {
        print("Updated bank or cc info, refreshing payments")
        self.loadPaymentInfo()
    }
    
}
