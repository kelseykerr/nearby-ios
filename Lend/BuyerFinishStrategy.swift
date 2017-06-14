//
//  BuyerFinishStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import SwiftyJSON


class BuyerFinishStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell

        if let request = history.request {
            let item = request.itemName ?? "ITEM"
             let inventoryListing = history.request?.requestType == .loaning || history.request?.requestType == .selling
            let responder = history.getResponseById(id: (history.transaction?.responseId)!)?.responder
            let responderName = responder?.firstName ?? "NAME"
            let name = (inventoryListing ? history.request?.user?.firstName :responderName) ?? "NAME"
            let price = history.transaction?.finalPriceInDollarFormat ?? "0.00"
            let action = request.type == RequestType.renting.rawValue || request.type == RequestType.loaning.rawValue ? "Borrowed" : "Bought"
            cell.message = "\(action) a \(item) from \(name) for \(price)"
            
            cell.stateColor = UIColor.nbBlue
            cell.state = "FULFILLED"
            
            cell.time = request.getElapsedTimeAsString()
            
            cell.userImage = UIImage(named: "User-64")
            
            if inventoryListing {
                if let pictureURL = request.user?.imageUrl {
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
            } else {
                if let pictureURL = responder?.imageUrl {
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
            }
        }
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Buyer", message: nil, preferredStyle: .actionSheet)
        
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
        transactionDetailVC.mode = .none
        return transactionDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        
        return []
    }

    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return false
    }
    
}
