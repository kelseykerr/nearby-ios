//
//  SellerExchangeStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

class SellerExchangeStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! HistoryTransactionTableViewCell
        let isInventoryRequest = history.request?.type == RequestType.selling.rawValue || history.request?.type == RequestType.loaning.rawValue
        var name = ""
        let response = history.responses[0]
        cell.userImage = UIImage(named: "User-64")
        if isInventoryRequest {
            name = response.responder?.firstName ?? "NAME"
            if let pictureURL = response.responder?.imageUrl {
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
            name = history.request?.user?.firstName ?? "NAME"
            
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

        }
        let item = history.request?.itemName ?? "ITEM"
        let action = history.request?.type == RequestType.selling.rawValue || history.request?.type == RequestType.buying.rawValue ? "Selling" : "Loaning"
        
        cell.message = "\(action) a \(item) to \(name)"
        
        if (history.status == .seller_overrideExchange && !(history.transaction?.exchangeOverride?.declined)!) {
            cell.stateColor = UIColor.nbYellow
            cell.state = "EXCHANGE OVERRIDE PENDING APPROVAL"
            cell.exchangeTimeLabel.isHidden = true
            cell.exchangeLocationLabel.isHidden = true
            cell.timeTitleLabel.isHidden = true
            cell.locationTitleLabel.isHidden = true
        } else {
            cell.stateColor = UIColor.nbGreen
            cell.state = "AWAITING EXCHANGE"
            if (response.exchangeTime != nil && response.exchangeTime != 0) {
                cell.exchangeTimeLabel.isHidden = false
                cell.timeTitleLabel.isHidden = false
                let dateString = Utils.dateIntToFormattedString(time: response.exchangeTime!)
                cell.exchangeTime = dateString
            } else {
                cell.exchangeTimeLabel.isHidden = true
                cell.timeTitleLabel.isHidden = true
            }
            
            if (response.exchangeLocation != nil && response.exchangeLocation != "") {
                cell.exchangeLocationLabel.isHidden = false
                cell.locationTitleLabel.isHidden = false
                cell.exchangeLocation = response.exchangeLocation!
            } else {
                cell.exchangeLocationLabel.isHidden = true
                cell.locationTitleLabel.isHidden = true
            }
        }
        
//        cell.timeLabel.removeFromSuperview()
        cell.time = ""
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
        transactionDetailVC.mode = .seller_generate
        return transactionDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let exchange = UITableViewRowAction(style: .normal, title: "Exchange") { action, index in
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
            
            historyVC.tableView.isEditing = false
        }
        exchange.backgroundColor = UIColor.nbBlue
        
        return [exchange]
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
