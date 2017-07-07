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
    
    @IBOutlet var accountNumber: UILabel!
    @IBOutlet var routingNumber: UILabel!
    @IBOutlet var creditCardNumber: UILabel!
    @IBOutlet var ccExp: UILabel!
    
    var user: NBUser?
    var paymentInfo: NBPayment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPaymentInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BanksAndCardsToPaymentSegue" {
            let paymentTableViewController = segue.destination as! PaymentTableViewController
            paymentTableViewController.delegate = self
        }
        else if segue.identifier == "BanksAndCardsToBankSegue" {
            let directDepositTableViewController = segue.destination as! DirectDepositTableViewController
            directDepositTableViewController.delegate = self
        }
    }

    func loadPaymentInfo() {
        let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Fetching")
        
        NBPayment.fetchPaymentInfo { (result, error) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            
            if let error = error {
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
