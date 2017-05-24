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

        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! HistoryTransactionTableViewCell
        
        let action = (history.request?.rental)! ? "Borrowing" : "Buying";
        let response = history.getResponseById(id: (history.transaction?.responseId)!)
        let sellerName = response?.seller?.firstName ?? "NAME"
        let item = history.request?.itemName ?? "ITEM"
        
        cell.message = "\(action) a \(item) from \(sellerName)"
        
        if (history.status == .buyer_overrideExchange && !(history.transaction?.exchangeOverride?.declined)!) {
            cell.stateColor = UIColor.nbYellow
            cell.state = "Exchange Override Pending Your Approval"
            let dateTimeStamp = NSDate(timeIntervalSince1970:Double((history.transaction?.exchangeOverride?.time)!)/1000)  //UTC time
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone.local //Edit
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.dateStyle = DateFormatter.Style.full
            dateFormatter.timeStyle = DateFormatter.Style.short
            let dateExchanged = dateFormatter.string(from: dateTimeStamp as Date)
            let messageString = "Did you exchange the \(item) with \(sellerName) on \(dateExchanged)"
            let alert = UIAlertController(title: "Confirm Exchange", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "yes", style: UIAlertActionStyle.default, handler: { action in
                switch action.style {
                case .default:
                    print("default")
                    history.transaction?.exchangeOverride?.buyerAccepted = true
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
                    history.transaction?.exchangeOverride?.buyerAccepted = false
                    history.transaction?.exchangeOverride?.declined = true
                    self.respondToOverride(t: history.transaction!, historyVC: historyVC)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }
            }))
            cell.exchangeTimeLabel.isHidden = true
            cell.exchangeLocationLabel.isHidden = true
            historyVC.present(alert, animated: true, completion: nil)
        } else {
            cell.stateColor = UIColor.nbGreen
            cell.state = "AWAITING EXCHANGE"
            if (response?.exchangeTime != nil && response?.exchangeTime != 0) {
                cell.exchangeTimeLabel.isHidden = false
                let attrText = NSMutableAttributedString(string: "")
                let boldFont = UIFont.boldSystemFont(ofSize: 14)
                let smallFont = UIFont.systemFont(ofSize: 14)
                let boldLabel = NSMutableAttributedString(string: "exchange time: ", attributes: [NSFontAttributeName: boldFont])
                attrText.append(boldLabel)
                let dateString = Utils.dateIntToFormattedString(time: (response?.exchangeTime!)!)
                attrText.append(NSMutableAttributedString(string: dateString, attributes: [NSFontAttributeName: smallFont]))
                cell.exchangeTimeLabel.attributedText = attrText
            } else {
                cell.exchangeTimeLabel.isHidden = true
            }
            
            if (response?.exchangeLocation != nil && response?.exchangeLocation != "") {
                cell.exchangeLocationLabel.isHidden = false
                let attrText = NSMutableAttributedString(string: "")
                let boldFont = UIFont.boldSystemFont(ofSize: 14)
                let smallFont = UIFont.systemFont(ofSize: 14)
                let boldLabel = NSMutableAttributedString(string: "exchange location: ", attributes: [NSFontAttributeName: boldFont])
                attrText.append(boldLabel)
                attrText.append(NSMutableAttributedString(string: (response?.exchangeLocation!)!, attributes: [NSFontAttributeName: smallFont]))
                cell.exchangeLocationLabel.attributedText = attrText
            } else {
                cell.exchangeLocationLabel.isHidden = true
            }
        }
        cell.time = history.request?.getElapsedTimeAsString()
        
        cell.userImage = UIImage(named: "User-64")
        
        let seller = history.getResponseById(id: (history.transaction?.responseId)!)?.seller
        if let pictureURL = seller?.imageUrl {
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
        transactionDetailVC.mode = .buyer_scan
        return transactionDetailVC
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
        exchange.backgroundColor = UIColor.nbBlue
        
        return [exchange]
    }

    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
