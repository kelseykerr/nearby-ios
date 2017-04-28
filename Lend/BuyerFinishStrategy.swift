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
        cell.exchangeTimeLabel.isHidden = true
        cell.exchangeLocationLabel.isHidden = true
        let item = history.request?.itemName ?? "ITEM"
        var text = ""
        if (history.request?.rental)! {
            text = "Borrowed a "
        } else {
            text = "Bought a "
        }
        text += "\(item) from " + (history.responses[0].seller?.firstName)!
        let price = history.transaction?.finalPriceInDollarFormat ?? "0.00"
        text += " for \(price)"
        cell.messageLabel.text = text;
        
        //add white line so that transaction card doesn't place yellow line on scroll
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let start = CGPoint.init(x: 5, y: 1)
        let end = CGPoint.init(x:5, y:99)
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 7
        line.lineJoin = kCALineJoinRound
        cell.layer.addSublayer(line)
 
        cell.historyStateLabel.backgroundColor = UIColor.nbBlue
        cell.historyStateLabel.text = " FULFILLED "
        
        cell.timeLabel.text = history.request?.getElapsedTimeAsString()
        
        cell.userImageView.image = UIImage(named: "User-64")
        cell.setNeedsLayout()
        
        let seller = history.getResponseById(id: (history.transaction?.responseId)!)?.seller
        
        if let pictureURL = seller?.imageUrl {
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
