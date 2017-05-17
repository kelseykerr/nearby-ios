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
        cell.message = "Please confirm price for \(item)"
        
        cell.stateColor = UIColor.nbYellow
        cell.state = "CONFIRM PRICE!"
        
//        cell.timeLabel.removeFromSuperview()
        cell.time = ""
        
        cell.userImage = UIImage(named: "User-64")
        
        if let pictureURL = history.request?.user?.imageUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryRequestTableViewCell? {
                    cellToUpdate.userImage = image
                }
            })
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let navVC = storyboard.instantiateViewController(
            withIdentifier: "ConfirmPriceNavigationController") as? UINavigationController else {
                assert(false, "Misnamed view controller")
                return cell
        }
        let confirmVC = (navVC.childViewControllers[0] as! ConfirmPriceTableViewController)
        confirmVC.delegate = historyVC
        confirmVC.history = history
        historyVC.present(navVC, animated: true, completion: nil)
        
        historyVC.tableView.isEditing = false

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
                return UIViewController()
        }
        transactionDetailVC.delegate = historyVC
        transactionDetailVC.history = history
        transactionDetailVC.mode = .confirm
        return transactionDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        
        let confirm = UITableViewRowAction(style: .normal, title: "Confirm") { action, index in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "ConfirmPriceNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let confirmVC = (navVC.childViewControllers[0] as! ConfirmPriceTableViewController)
            confirmVC.delegate = historyVC
            confirmVC.history = history
            historyVC.present(navVC, animated: true, completion: nil)
            
            historyVC.tableView.isEditing = false
        }
        confirm.backgroundColor = UIColor.nbBlue
        
        return [confirm]
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
