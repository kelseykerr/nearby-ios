//
//  BuyerFinishStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class BuyerFinishStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! HistoryTransactionTableViewCell
        
        let item = history.request?.itemName ?? "ITEM"
        let text = " have successfully completed transaction for "
        let attrText = NSMutableAttributedString(string: "")
        let boldFont = UIFont.boldSystemFont(ofSize: 15)
        let boldFullname = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldFullname)
        attrText.append(NSMutableAttributedString(string: text))
        
        let boldItemName = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldItemName)
        attrText.append(NSMutableAttributedString(string: "."))
        
        cell.messageLabel.attributedText = attrText

        cell.historyStateLabel.backgroundColor = UIColor.wisteria
        cell.historyStateLabel.textColor = UIColor.white
        cell.historyStateLabel.text = "FINISH"
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
        else if history.request?.user?.lastName == "App" {
            cell.userImageView.image = UIImage(named: "IMG_1426")
            cell.setNeedsLayout()
        }
        else if history.request?.user?.lastName == "AppTwo" {
            cell.userImageView.image = UIImage(named: "Penny")
            cell.setNeedsLayout()
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
        guard let responseDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                assert(false, "Misnamed view controller")
        }
        return responseDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let detail = UITableViewRowAction(style: .normal, title: "Detail") { action, index in
            print("detail button tapped")
        }
        detail.backgroundColor = UIColor.lightGray
        
        return [detail]
    }

}
