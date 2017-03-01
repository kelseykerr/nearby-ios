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
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        
        let item = history.request?.itemName ?? "ITEM"
        cell.messageLabel?.text = "You have successfully completed transaction for \(item)."
        
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
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
