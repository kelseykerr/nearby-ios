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
//        cell.exchangeTimeLabel.isHidden = true
//        cell.exchangeLocationLabel.isHidden = true
        let item = history.request?.itemName ?? "ITEM"
        
//        cell.messageLabel.text = "You have successfully completed transaction for \(item)."
        cell.messageLabel.text = "Awaiting seller to confirm price for \(item)."
        cell.messageLabel.frame.size = CGSize(width: 288, height: 20) // reset
        cell.messageLabel.sizeToFit()
        
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let start = CGPoint.init(x: 5, y: 1)
        let end = CGPoint.init(x:5, y:99)
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.nbYellow.cgColor
        line.lineWidth = 7
        line.lineJoin = kCALineJoinRound
        cell.layer.addSublayer(line)
        /*
         let attrText = NSMutableAttributedString(string: "")
         let boldFont = UIFont.boldSystemFont(ofSize: 15)
         
         let boldYou = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
         attrText.append(boldYou)
         
         attrText.append(NSMutableAttributedString(string: " have successfully completed transaction for "))
         
         let boldItemName = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
         attrText.append(boldItemName)
         
         attrText.append(NSMutableAttributedString(string: "."))
         
         cell.messageLabel.attributedText = attrText
         */
        
        cell.historyStateLabel.backgroundColor = UIColor.purple
        cell.historyStateLabel.text = " PROCESSING PAYMENT "
        cell.historyStateLabel.sizeToFit()
        
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
