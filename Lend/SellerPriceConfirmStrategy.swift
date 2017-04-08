//
//  SellerPriceConfirmStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/24/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class SellerPriceConfirmStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        
        let item = history.request?.itemName ?? "ITEM"
        
        cell.messageLabel.text = "Please confirm price for \(item)."
        /*
         let attrText = NSMutableAttributedString(string: "")
         let boldFont = UIFont.boldSystemFont(ofSize: 15)
         
         let boldYou = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
         attrText.append(boldYou)
         
         attrText.append(NSMutableAttributedString(string: " have successfully completed transaction for "))
         
         let boldItemName = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
         attrText.append(boldItemName)
         
         attrText.append(NSMutableAttributedString(string: "."))
         
         cell.messageLabel.attributedText = attrText
         */
        
        cell.historyStateLabel.backgroundColor = UIColor.purple
        cell.historyStateLabel.text = "Price Confirm"
        
        cell.timeLabel.text = history.request?.getElapsedTimeAsString()
        
        cell.userImageView.image = UIImage(named: "User-64")
        cell.setNeedsLayout()
        
        if let pictureURL = history.request?.user?.pictureUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryRequestTableViewCell? {
                    cellToUpdate.userImageView?.image = image
                    cellToUpdate.setNeedsLayout()
                }
            })
        }
        
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let transactionDetailVC = storyboard.instantiateViewController(
            withIdentifier: "TransactionDetailTableViewController") as? TransactionDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return UIViewController ()
        }
        transactionDetailVC.delegate = historyVC
        transactionDetailVC.history = history
        transactionDetailVC.mode = .confirm
        return transactionDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        
        let confirm = UITableViewRowAction(style: .normal, title: "Confirm") { action, index in
            
            if let transaction = history.transaction {
                NBTransaction.verifyTransactionPrice(id: transaction.id!, transaction: transaction) { error in
                    print("price verified test")
                    if let error = error {
                        let alert = Utils.createServerErrorAlert(error: error)
                        historyVC.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
            historyVC.tableView.isEditing = false
        }
        confirm.backgroundColor = UIColor.purple
        
        return [confirm]
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
