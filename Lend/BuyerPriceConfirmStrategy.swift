//
//  BuyerPriceConfirmStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/24/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class BuyerPriceConfirmStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        let item = history.request?.itemName ?? "ITEM"
        
        cell.message = "Waiting for seller to confirm price for \(item)."
        
        cell.stateColor = UIColor.purple
        cell.state = "PROCESSING PAYMENT"
        
        cell.time = history.request?.getElapsedTimeAsString()
        
        cell.userImage = UIImage(named: "User-64")
        
        let response = history.getResponseById(id: (history.transaction?.responseId)!)
        let isInventoryRequest = history.request?.type == RequestType.selling.rawValue || history.request?.type == RequestType.loaning.rawValue
        if isInventoryRequest {
            let imageUrl = history.request?.user?.imageUrl
            setUserImage(historyVC: historyVC, indexPath: indexPath, history: history, imageUrl: imageUrl)
        } else {
            let imageUrl = response?.responder?.imageUrl
            setUserImage(historyVC: historyVC, indexPath: indexPath, history: history, imageUrl: imageUrl)
        }
        return cell
    }
    
    private func setUserImage(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory, imageUrl: String?) {
        if let pictureURL = imageUrl {
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
    
    func heightForRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> CGFloat {
        return 80
    }
    
}
