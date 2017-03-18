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

            let request = history.request
            let item = history.request?.itemName ?? "ITEM"
            
            let text = " want to \(((request?.rental)! ? "borrow" : "buy")) "
            let attrText = NSMutableAttributedString(string: "")
            let boldFont = UIFont.boldSystemFont(ofSize: 15)
            let boldFullname = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldFullname)
            attrText.append(NSMutableAttributedString(string: text))
            
            let boldItemName = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldItemName)
            attrText.append(NSMutableAttributedString(string: "."))
            
            //setting cell's views
            cell.messageLabel.attributedText = attrText
            cell.messageLabel.sizeToFit()
            
            cell.historyStateLabel.backgroundColor = UIColor.energy
            cell.historyStateLabel.textColor = UIColor.white
            cell.historyStateLabel.text = "BUYER CONFIRM"
            
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

            return cell
        }
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        if (indexPath as NSIndexPath).row == 0 {
            let alertController = UIAlertController(title: "BuyerConfirmRequest Buyer", message: nil, preferredStyle: .actionSheet)
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                if let request = history.request {
                    NBRequest.removeRequest(request, completionHandler: { error in
                        print("Request deleted")
                    })
                }
            }
            alertController.addAction(deleteAction)
        
            return alertController
        }
        else {
            let alertController = UIAlertController(title: "BuyerConfirmOffer Buyer", message: nil, preferredStyle: .actionSheet)
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        
            let acceptAction = UIAlertAction(title: "Accept", style: .default) { action in
                let response = history.responses[(indexPath as NSIndexPath).row - 1]
                response.buyerStatus = BuyerStatus(rawValue: "ACCEPTED")
                
                NBResponse.editResponse(response, completionHandler: { error in
                    print("Accept an offer")
                })
            }
            alertController.addAction(acceptAction)
        
            let declineAction = UIAlertAction(title: "Decline", style: .default) { action in
            }
            alertController.addAction(declineAction)
        
            return alertController
        }
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let responseDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                assert(false, "Misnamed view controller")
//                return nil
        }
        return responseDetailVC
//        historyVC.navigationController?.pushViewController(responseDetailVC, animated: true)
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        if (indexPath as NSIndexPath).row == 0 {
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
//                print("delete button tapped")
                if let request = history.request {
                    NBRequest.removeRequest(request, completionHandler: { error in
                        print("Request deleted")
                    })
                    
                    historyVC.tableView.isEditing = false
                    print("Request delete button pressed")
                }
            }
            delete.backgroundColor = UIColor.cinnabar
            
            return [delete]
        }
        else {
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                let response = history.responses[(indexPath as NSIndexPath).row - 1]
                response.buyerStatus = BuyerStatus(rawValue: "ACCEPTED")
                
                NBResponse.editResponse(response, completionHandler: { error in
                    print("Accept an offer")
                    historyVC.tableView.isEditing = false
                })
                
                print("accept button tapped")
            }
            accept.backgroundColor = UIColor.pictonBlue
            
            let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
                print("decline button tapped")
            }
            decline.backgroundColor = UIColor.cinnabar
            
            return [decline, accept]
        }
    }
    
}
