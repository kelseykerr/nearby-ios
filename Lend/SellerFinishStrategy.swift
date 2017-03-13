//
//  SellerFinishStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class SellerFinishStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! HistoryTransactionTableViewCell
        
        let item = history.request?.itemName ?? "ITEM"
        cell.messageLabel?.text = "You have successfully completed transaction for \(item)."
        
        cell.historyStateLabel.backgroundColor = UIColor.wisteria
        cell.historyStateLabel.textColor = UIColor.white
        cell.historyStateLabel.text = "FINISH"
        cell.timeLabel.text = history.request?.getElapsedTimeAsString()
        
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Seller", message: nil, preferredStyle: .actionSheet)
        
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
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit button tapped")
        }
        edit.backgroundColor = UIColor.lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
        }
        delete.backgroundColor = UIColor.red
        
        let delete2 = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
        }
        delete2.backgroundColor = UIColor.green
        
        let delete3 = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
        }
        delete3.backgroundColor = UIColor.purple
        
        return [delete3, delete2, delete, edit]
    }
    
}
