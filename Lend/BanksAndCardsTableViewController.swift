//
//  BanksAndCardsTableViewController.swift
//  Nearby
//
//  Created by Kerr, Kelsey on 4/9/17.
//  Copyright © 2017 Iuxta Inc. All rights reserved.
//

import UIKit

class BanksAndCardsTableViewController: UITableViewController {
    var user: NBUser?
    var paymentInfo: NBPayment?
    
    @IBOutlet weak var accountNumber: UILabel!
    @IBOutlet weak var routingNumber: UILabel!

    @IBOutlet weak var creditCardNumber: UILabel!
    @IBOutlet weak var ccExp: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPaymentInfo()
    }

    func loadPaymentInfo() {
        NBPayment.fetchPaymentInfo { result in
         
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let paymentInfo = result.value else {
                print("no payment info fetched")
                return
            }
            
            self.paymentInfo = paymentInfo
            
            if (self.paymentInfo?.bankAccountLast4 != nil &&
                self.paymentInfo?.routingNumber != nil) {
                let bankString = "Account Number: " + (self.paymentInfo?.bankAccountLast4)!
                self.accountNumber.text = bankString
                self.routingNumber.text = "Routing Number: " + (self.paymentInfo?.routingNumber)!
            } else {
                self.accountNumber.text = "Please link your bank account!"
            }
            
            if (self.paymentInfo?.ccMaskedNumber != nil &&
                self.paymentInfo?.ccExpDate != nil) {
                let ccString = "Card Number: " + (self.paymentInfo?.ccMaskedNumber)!;
                self.creditCardNumber.text = ccString
                let ccExp = "Exp Date: " + (self.paymentInfo?.ccExpDate)!
                self.ccExp.text = ccExp
            } else {
                self.creditCardNumber.text = "Please add a credit card!"
            }
            
            self.tableView.reloadData()
        }
    }

    
}
