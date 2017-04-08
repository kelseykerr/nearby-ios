//
//  SellerSellerConfirmStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class SellerSellerConfirmStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        
        let name = history.request?.user?.fullName ?? "NAME"
        let item = history.request?.itemName ?? "ITEM"
        cell.messageLabel?.text = "\(name) has accepted your offer for \(item). Please confirm to proceed."
        
        cell.historyStateLabel.backgroundColor = UIColor.energy
        cell.historyStateLabel.textColor = UIColor.white
        cell.historyStateLabel.text = "SELLER CONFIRM"
        cell.timeLabel.text = history.request?.getElapsedTimeAsString()
        
        return cell
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "SellerConfirm Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { action in
            print("accepted:")
//            if let response = self.getResponse2(indexPath) {
//                print("got an response")
//                
//                //                response.buyerStatus = BuyerStatus(rawValue: "ACCEPTED")
//                response.sellerStatus = SellerStatus(rawValue: "ACCEPTED")
//                
//                NBResponse.editResponse(response, completionHandler: { error in
//                    print("done")
//                })
//            }
        }
        alertController.addAction(acceptAction)
        
        let declineAction = UIAlertAction(title: "Decline", style: .default) { action in
            // ...
        }
        alertController.addAction(declineAction)
        
        return alertController
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let responseDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return UIViewController ()
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

    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
