//
//  SellerClosedStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/24/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import SwiftyJSON


class SellerClosedStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        let inventoryListing = history.request?.requestType == .loaning || history.request?.requestType == .selling
        let item = history.request?.itemName ?? "ITEM"
        var responder: NBUser?
        if inventoryListing {
            if (history.request?.isMyRequest() ?? false) {
                let responseId = history.transaction?.responseId
                if let respId = responseId {
                    let response = history.getResponseById(id: respId)
                    responder = response?.responder
                }
            } else {
                let action = history.request?.requestType == .loaning ? "borrow" : "buy"
                let name = history.request?.user?.firstName ?? "No Name"
                cell.message = "Requested to \(action ) a \(item) from \(name)"
            }
        } else {
            let name = (inventoryListing ? responder?.firstName ?? "NO NAME" : history.request?.user?.firstName) ?? "NAME"
            let action = history.request?.requestType.getAsVerb()
            let direction = inventoryListing ? "to" : "from"
            
            cell.message = "Offered to \(action ?? "loan") a \(item) \(direction) \(name)"
        }
        
        cell.stateColor = UIColor.nbRed
        cell.state = "CLOSED"
        
        cell.time = history.request?.getElapsedTimeAsString()
        
        cell.userImage = UIImage(named: "User-64")
        
        if inventoryListing {
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

        } else {
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
        guard let requestDetailVC = storyboard.instantiateViewController(
            withIdentifier: "RequestDetailTableViewController") as? RequestDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return UIViewController()
        }
        requestDetailVC.request = history.request
        requestDetailVC.mode = .none
        return requestDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        
        return []
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return false
    }
    
}
