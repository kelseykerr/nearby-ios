//
//  BuyerExchangeStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class BuyerExchangeStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
//        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! HistoryTransactionTableViewCell
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        
        let name = history.getResponseById(id: (history.transaction?.responseId)!)?.seller?.fullName ?? "NAME"
        let item = (history.request?.itemName)!
//        cell.messageLabel?.text = "You are meeting \(name) to exchange \(item)."
        
        let text1 = " are meeting "
        let text2 = " to exchange "
        let attrText = NSMutableAttributedString(string: "")
        let boldFont = UIFont.boldSystemFont(ofSize: 15)
        let boldFullname = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldFullname)
        attrText.append(NSMutableAttributedString(string: text1))
        let boldFullname2 = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldFullname2)
        attrText.append(NSMutableAttributedString(string: text2))
        
        let boldItemName = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldItemName)
        attrText.append(NSMutableAttributedString(string: "."))
        
        //setting cell's views
        cell.messageLabel.attributedText = attrText
        cell.messageLabel.sizeToFit()
        
//        cell.historyStateLabel.backgroundColor = UIColor.mountainMedow
        cell.historyStateLabel.backgroundColor = UIColor.nbGreen
        cell.historyStateLabel.textColor = UIColor.white
        cell.historyStateLabel.text = "EXCHANGE"
        cell.timeLabel.text = history.request?.getElapsedTimeAsString()
        
        cell.userImageView.image = UIImage(named: "User-64")
        cell.setNeedsLayout()
        
        let seller = history.getResponseById(id: (history.transaction?.responseId)!)?.seller
        if let pictureURL = seller?.pictureUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
//                if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryTransactionTableViewCell? {
                if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryRequestTableViewCell? {
                    cellToUpdate.userImageView?.image = image
                    cellToUpdate.setNeedsLayout()
                }
            })
        }
        
//        cell.userImageView2.image = UIImage(named: "User-64")
//        cell.setNeedsLayout()
//        
//        let seller = history.getResponseById(id: (history.transaction?.responseId)!)?.seller
//        
//        if let pictureURL = seller?.pictureUrl {
//            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
//                guard error == nil else {
//                    print(error!)
//                    return
//                }
//                if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryTransactionTableViewCell? {
//                    cellToUpdate.userImageView2?.image = image
//                    cellToUpdate.setNeedsLayout()
//                }
//            })
//        }
        
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Exchange Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let exchangeAction = UIAlertAction(title: "Exchange", style: .default) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRScannerNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let scannerVC = (navVC.childViewControllers[0] as! QRScannerViewController)
            scannerVC.delegate = historyVC
            scannerVC.transaction = history.transaction
            historyVC.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(exchangeAction)
        
        return alertController
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let responseDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                assert(false, "Misnamed view controller")
        }
        return responseDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let exchange = UITableViewRowAction(style: .normal, title: "Exchange") { action, index in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRScannerNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let scannerVC = (navVC.childViewControllers[0] as! QRScannerViewController)
            scannerVC.delegate = historyVC
            scannerVC.transaction = history.transaction
            historyVC.present(navVC, animated: true, completion: nil)
            
            historyVC.tableView.isEditing = false
        }
//        exchange.backgroundColor = UIColor.mountainMedow
        exchange.backgroundColor = UIColor.lightGray
        
        return [exchange]
    }

}
