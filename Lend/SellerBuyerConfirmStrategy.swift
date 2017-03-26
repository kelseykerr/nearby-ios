//
//  SellerBuyerConfirmStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class SellerBuyerConfirmStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
            
            let name = history.request?.user?.shortName ?? "NAME"
            let item = history.request?.itemName ?? "ITEM"
            let rent = (history.request?.rental)! ? "lend" : "sell"
            let price = history.responses[0].priceInDollarFormat
            
//            if history.responses[0].buyerStatus == .declined {
//                cell.messageLabel.text = "Your offer for \(item) has been declined by \(name)."
//            }
//            else {
                cell.messageLabel.text = "You are offering to \(rent) \(item) to \(name) for \(price)."
//            }

            
/*
            let attrText = NSMutableAttributedString(string: "")
            let boldFont = UIFont.boldSystemFont(ofSize: 15)
            
            let boldYou = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldYou)
            
            attrText.append(NSMutableAttributedString(string: " are offering to \(rent) "))
            
            let boldItem = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldItem)
            
            attrText.append(NSMutableAttributedString(string: " to "))
            
            let boldName = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldName)
            
            attrText.append(NSMutableAttributedString(string: " for "))
            
            let boldPrice = NSMutableAttributedString(string: price, attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldPrice)
            
            attrText.append(NSMutableAttributedString(string: "."))
            
            cell.messageLabel.attributedText = attrText
            cell.messageLabel.sizeToFit()
*/
            
            cell.historyStateLabel.backgroundColor = UIColor.nbYellow
            cell.historyStateLabel.text = "Buyer Confirm"
            cell.timeLabel.text = history.request?.getElapsedTimeAsString()
            
            cell.userImageView.image = UIImage(named: "User-64")
            cell.setNeedsLayout()
            
            if let pictureURL = history.request?.user?.pictureUrl {
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
        else {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "ResponseCell", for: indexPath) as! HistoryResponseTableViewCell
            
                let name: String = history.request?.user?.firstName ?? "NAME"
                let price = history.responses[indexPath.row - 1].offerPrice ?? -9.99
                cell.messageLabel?.text = "You are offering to sell it to \(name) for $\(price)."
            
            return cell
        }
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "BuyerConfirm Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let response = history.responses[0]
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let responseDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                assert(false, "Misnamed view controller")
        }
        responseDetailVC.mode = .seller
        responseDetailVC.delegate = historyVC
        responseDetailVC.response = response
        return responseDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        
        return []
    }

    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return false
    }
    
}
