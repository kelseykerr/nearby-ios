//
//  BuyerBuyerConfirmStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class BuyerBuyerConfirmStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
            
            let item = history.request?.itemName ?? "ITEM"
                cell.messageLabel?.text = "You want to borrow \(item)."
            
            cell.historyStateLabel.backgroundColor = UIColor.red
            cell.historyStateLabel.textColor = UIColor.white
            cell.historyStateLabel.text = "BUYER CONFIRM"
            cell.timeLabel.text = "2 Days Ago"
            
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
        else {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "ResponseCell", for: indexPath) as! HistoryResponseTableViewCell
            
            let name: String = history.responses[indexPath.row - 1].seller?.fullName ?? "NAME"
            let price = history.responses[indexPath.row - 1].offerPrice ?? -9.99
                cell.messageLabel?.text = "\(name) is offering to sell it to you for $\(price)."
            
            cell.userImageView.image = UIImage(named: "User-64")
            cell.setNeedsLayout()
            
            if let pictureURL = history.responses[indexPath.row - 1].seller?.pictureUrl {
                NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryResponseTableViewCell? {
                        cellToUpdate.userImageView?.image = image
                        cellToUpdate.setNeedsLayout()
                    }
                })
            }
            else if history.responses[indexPath.row - 1].seller?.lastName == "App" {
                cell.userImageView.image = UIImage(named: "IMG_1426")
                cell.setNeedsLayout()
            }
            else if history.responses[indexPath.row - 1].seller?.lastName == "AppTwo" {
                cell.userImageView.image = UIImage(named: "Penny")
                cell.setNeedsLayout()
            }

            return cell
        }
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        if (indexPath as NSIndexPath).row == 0 {
            let alertController = UIAlertController(title: "BuyerConfirmRequest Buyer", message: nil, preferredStyle: .actionSheet)
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        
            let OKAction = UIAlertAction(title: "Delete", style: .destructive) { action in
//                if let request = self.getRequest((indexPath as NSIndexPath).section) {
//                    NBRequest.removeRequest(request, completionHandler: { error in
//                        print("Request Deleted")
//                    })
//                }
            }
            alertController.addAction(OKAction)
        
            return alertController
        }
        else {
            let alertController = UIAlertController(title: "BuyerConfirmOffer Buyer", message: nil, preferredStyle: .actionSheet)
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        
            let acceptAction = UIAlertAction(title: "Accept", style: .default) { action in
                print("accepted:")
//                if let response = self.getResponse(indexPath) {
//                    print("got an response")
//                
//                    response.buyerStatus = BuyerStatus(rawValue: "ACCEPTED")
//                
//                    NBResponse.editResponse(response, completionHandler: { error in
//                        print("done")
//                    })
//                }
            }
            alertController.addAction(acceptAction)
        
            let declineAction = UIAlertAction(title: "Decline", style: .default) { action in
                // ...
            }
            alertController.addAction(declineAction)
        
            return alertController
        }
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        if (indexPath as NSIndexPath).row == 0 {
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                print("edit button tapped")
            }
            edit.backgroundColor = UIColor.lightGray
            
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                print("delete button tapped")
            }
            delete.backgroundColor = UIColor.red
            
            return [delete, edit]
        }
        else {
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                print("accept button tapped")
            }
            accept.backgroundColor = UIColor.blue
            
            let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
                print("decline button tapped")
            }
            decline.backgroundColor = UIColor.red
            
            return [decline, accept]
        }
    }
    
}
