//
//  BuyerReturnStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class BuyerReturnStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! HistoryTransactionTableViewCell
        
        let response = history.getResponseById(id: (history.transaction?.responseId)!)
        let responderName = response?.responder?.firstName ?? "NAME"
        let item = history.request?.itemName ?? "ITEM"
        
        let action = history.request?.requestType.getAsInflected()
        let inventoryRequest = history.request?.requestType == .loaning || history.request?.requestType == .selling
        let direction = inventoryRequest ? "to" : "from"
        cell.message = "\(action!) \(item) \(direction) \(responderName)"
        
        if (history.status == .buyer_overrideReturn) {
            cell.stateColor = UIColor.nbYellow
            cell.state = "Return Override Pending Approval"
            cell.exchangeTimeLabel.isHidden = true
            cell.exchangeLocationLabel.isHidden = true
            cell.timeTitleLabel.isHidden = true
            cell.locationTitleLabel.isHidden = true
        } else {
            cell.stateColor = UIColor.nbYellow
            cell.state = "AWAITING RETURN"
            if (response?.returnTime != nil && response?.returnTime != 0) {
                cell.exchangeTimeLabel.isHidden = false
                cell.timeTitleLabel.isHidden = false
                let dateString = Utils.dateIntToFormattedString(time: (response?.returnTime!)!)
                cell.exchangeTime = dateString
            } else {
                cell.exchangeTimeLabel.isHidden = true
                cell.timeTitleLabel.isHidden = true
            }
            
            if (response?.returnLocation != nil && response?.returnLocation != "") {
                cell.exchangeLocationLabel.isHidden = false
                cell.locationTitleLabel.isHidden = false
                cell.exchangeLocation = (response?.returnLocation!)
            } else {
                cell.exchangeLocationLabel.isHidden = true
                cell.locationTitleLabel.isHidden = true
            }
        }
        
        cell.time = history.request?.getElapsedTimeAsString()
        
        cell.userImage = UIImage(named: "User-64")
        
        let responder = history.getResponseById(id: (history.transaction?.responseId)!)?.responder
        
        if inventoryRequest {
            if let pictureURL = history.request?.user?.imageUrl {
                NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryTransactionTableViewCell? {
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
                    if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryTransactionTableViewCell? {
                        cellToUpdate.userImage = image
                    }
                })
            }

        }
    
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Exchange Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let exchangeAction = UIAlertAction(title: "Exchange", style: .default) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRGeneratorNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let generatorVC = (navVC.childViewControllers[0] as! QRGeneratorViewController)
            generatorVC.delegate = historyVC
            generatorVC.transaction = history.transaction
            historyVC.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(exchangeAction)
        
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
        transactionDetailVC.mode = .buyer_generate
        return transactionDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let exchange = UITableViewRowAction(style: .normal, title: "Return") { action, index in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if (history.request?.type == RequestType.selling.rawValue || history.request?.type == RequestType.loaning.rawValue) {
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

            } else {
                guard let navVC = storyboard.instantiateViewController(
                    withIdentifier: "QRGeneratorNavigationController") as? UINavigationController else {
                        assert(false, "Misnamed view controller")
                        return
                }
                let generatorVC = (navVC.childViewControllers[0] as! QRGeneratorViewController)
                generatorVC.delegate = historyVC
                generatorVC.transaction = history.transaction
                historyVC.present(navVC, animated: true, completion: nil)
                
                historyVC.tableView.isEditing = false

            }
        }
        exchange.backgroundColor = UIColor.nbBlue
        
        return [exchange]
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
