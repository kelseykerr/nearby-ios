//
//  BuyerBuyerConfirmStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import SwiftyJSON

class BuyerBuyerConfirmStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell

            let request = history.request
            let item = history.request?.itemName ?? "ITEM"
            let rent = (request?.rental)! ? "borrow" : "buy"

            cell.messageLabel.text = "You want to \(rent) \(item)."
/*
            let attrText = NSMutableAttributedString(string: "")
            let boldFont = UIFont.boldSystemFont(ofSize: 15)
            
            let boldYou = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldYou)
            
            attrText.append(NSMutableAttributedString(string: " want to \(rent) "))
            
            let boldItemName = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldItemName)
            
            attrText.append(NSMutableAttributedString(string: "."))
            
            cell.messageLabel.attributedText = attrText
*/
            
            cell.historyStateLabel.backgroundColor = UIColor.nbGreen
            cell.historyStateLabel.text = "open"
            
            cell.timeLabel.text = history.request?.getElapsedTimeAsString()
            
            cell.userImageView.image = UIImage(named: "User-64")
            cell.setNeedsLayout()
            
            if let pictureURL = history.request?.user?.imageUrl {
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
            
            let sellerName = history.responses[indexPath.row - 1].seller?.shortName ?? "NAME"
            let price = history.responses[indexPath.row - 1].priceInDollarFormat
            let rent = (history.request?.rental)! ? "lend" : "sell"

            cell.messageLabel.text = "\(sellerName) is offering to \(rent) it to you for \(price)."
/*
            let attrText = NSMutableAttributedString(string: "")
            let boldFont = UIFont.boldSystemFont(ofSize: 15)
            
            let boldName = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldName)
            
            attrText.append(NSMutableAttributedString(string: " is offering to \(rent) it to you for "))
            
            let boldPrice = NSMutableAttributedString(string: price, attributes: [NSFontAttributeName: boldFont])
            attrText.append(boldPrice)
            
            attrText.append(NSMutableAttributedString(string: "."))
            
            cell.messageLabel.attributedText = attrText
*/
            
            cell.userImageView.image = UIImage(named: "User-64")
            cell.setNeedsLayout()
            
            if let pictureURL = history.responses[indexPath.row - 1].seller?.imageUrl {
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
        
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let requestDetailVC = storyboard.instantiateViewController(
                withIdentifier: "RequestDetailTableViewController") as? RequestDetailTableViewController else {
                    assert(false, "Misnamed view controller")
                    return UIViewController()
            }
            requestDetailVC.mode = .buyer
            requestDetailVC.request = history.request
            requestDetailVC.delegate = historyVC
            return requestDetailVC
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let responseDetailVC = storyboard.instantiateViewController(
                withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                    assert(false, "Misnamed view controller")
                    return UIViewController()
            }
            responseDetailVC.response = history.responses[indexPath.row - 1]
            responseDetailVC.mode = .buyer
            responseDetailVC.delegate = historyVC
            return responseDetailVC
        }
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        if (indexPath as NSIndexPath).row == 0 {
            let delete = UITableViewRowAction(style: .normal, title: "Close") { action, index in
                print("Request close button pressed")
                
                historyVC.closed(history.request)
                
                historyVC.tableView.isEditing = false
            }
            delete.backgroundColor = UIColor.nbRed
            
            return [delete]
        }
        else {
            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                print("accept button tapped")
                
                let response = history.responses[(indexPath as NSIndexPath).row - 1]
                historyVC.accepted(response)
                
                historyVC.tableView.isEditing = false
            }
            accept.backgroundColor = UIColor.nbTurquoise
            
            let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
                print("decline button tapped")
                
                let response = history.responses[(indexPath as NSIndexPath).row - 1]
                historyVC.declined(response)
                
                historyVC.tableView.isEditing = false
            }
            decline.backgroundColor = UIColor.nbRed
            
            return [decline, accept]
        }
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
