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
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        
        let item = history.request?.itemName ?? "ITEM"
        cell.messageLabel?.text = "You have successfully completed transaction for \(item)."
        
        cell.historyStateLabel.backgroundColor = UIColor.blue
        cell.historyStateLabel.textColor = UIColor.white
        cell.historyStateLabel.text = "FINISH"
        cell.timeLabel.text = "2 Days Ago"
        
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Buyer", message: nil, preferredStyle: .actionSheet)
        
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
