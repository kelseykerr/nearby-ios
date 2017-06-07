//
//  SellerReturnStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class SellerReturnStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! HistoryTransactionTableViewCell
        
        let name = history.request?.user?.firstName ?? "NAME"
        let item = history.request?.itemName ?? "ITEM"
        let response = history.responses[0]
        let action = history.request?.requestType.getAsInflected()
        
        cell.message = "\(action!) a \(item) to \(name)"
        
        if (history.status == .seller_overrideReturn) {
            cell.stateColor = UIColor.nbYellow
            cell.state = "Return Override Pending Your Approval"
            let dateTimeStamp = NSDate(timeIntervalSince1970:Double((history.transaction?.returnOverride?.time)!)/1000)  //UTC time
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone.local //Edit
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.timeStyle = DateFormatter.Style.short
            let dateExchanged = dateFormatter.string(from: dateTimeStamp as Date)
            let messageString = "Did you exchange the \(item) with \(name) on \(dateExchanged)"
            let alert = UIAlertController(title: "Confirm Exchange", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "yes", style: UIAlertActionStyle.default, handler: { action in
                switch action.style {
                case .default:
                    print("default")
                    history.transaction?.returnOverride?.sellerAccepted = true
                    self.respondToOverride(t: history.transaction!, historyVC: historyVC)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }
            }))
            alert.addAction(UIAlertAction(title: "no", style: UIAlertActionStyle.default, handler: { action in
                switch action.style {
                case .default:
                    print("default")
                    history.transaction?.returnOverride?.sellerAccepted = false
                    history.transaction?.returnOverride?.declined = true
                    self.respondToOverride(t: history.transaction!, historyVC: historyVC)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }
            }))
            cell.exchangeTimeLabel.isHidden = true
            cell.exchangeLocationLabel.isHidden = true
            cell.timeTitleLabel.isHidden = true
            cell.locationTitleLabel.isHidden = true
            historyVC.present(alert, animated: true, completion: nil)
        } else {
            cell.stateColor = UIColor.nbYellow
            cell.state = "AWAITING RETURN"
            
            if (response.returnTime != nil && response.returnTime != 0) {
                cell.exchangeTimeLabel.isHidden = false
                cell.timeTitleLabel.isHidden = false
                let dateString = Utils.dateIntToFormattedString(time: response.returnTime!)
                cell.exchangeTime = dateString
            } else {
                cell.exchangeTimeLabel.isHidden = true
                cell.timeTitleLabel.isHidden = true
            }
            
            if (response.returnLocation != nil && response.returnLocation != "") {
                cell.exchangeLocationLabel.isHidden = false
                cell.locationTitleLabel.isHidden = false
                cell.exchangeLocation = response.returnLocation!
            } else {
                cell.exchangeLocationLabel.isHidden = true
                cell.locationTitleLabel.isHidden = true
            }
            
        }
        
//        cell.timeLabel.removeFromSuperview()
        cell.time = ""
        
        cell.userImage = UIImage(named: "User-64")
        
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
        
        return cell
    }
    
    func respondToOverride(t: NBTransaction, historyVC: HistoryTableViewController) {
        NBTransaction.putOverrideResponse(id: t.id!, transaction: t) { error in
            print(error)
            if let error = error {
                let alert = Utils.createServerErrorAlert(error: error)
                historyVC.present(alert, animated: true, completion: nil)
            }
            historyVC.refresh(self)
        }
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
        guard let transactionDetailVC = storyboard.instantiateViewController(
            withIdentifier: "TransactionDetailTableViewController") as? TransactionDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return UIViewController()
        }
        transactionDetailVC.delegate = historyVC
        transactionDetailVC.history = history
        transactionDetailVC.mode = .seller_scan
        return transactionDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let exchange = UITableViewRowAction(style: .normal, title: "Return") { action, index in
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
        exchange.backgroundColor = UIColor.nbBlue
        
        return [exchange]
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
