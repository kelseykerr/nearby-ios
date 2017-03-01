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
            
                let name: String = history.request?.user?.fullName ?? "NAME"
                let item = history.request?.itemName ?? "ITEM"
                cell.messageLabel?.text = "\(name) wants to borrow \(item)."
            
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
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let detail = UITableViewRowAction(style: .normal, title: "Detail") { action, index in
            print("detail button tapped")
        }
        detail.backgroundColor = UIColor.lightGray
        
        return [detail]
    }

}
