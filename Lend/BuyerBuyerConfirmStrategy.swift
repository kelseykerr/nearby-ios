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
            
            if let request = history.request {
                let item = request.itemName ?? "ITEM"
                let action = request.requestType.getAsVerb()
                
                if (request.type == RequestType.buying.rawValue || request.type == RequestType.renting.rawValue) {
                    cell.message = "Requested to \(action) a \(item)"
                } else {
                    if (request.type == RequestType.loaning.rawValue) {
                        cell.message = "Offering to \(action) out a \(item)"
                    } else if (request.type == RequestType.selling.rawValue) {
                        cell.message = "Selling a \(item)"
                    }
                }
                
                cell.stateColor = UIColor.nbGreen
                cell.state = "OPEN"
                
                cell.time = request.getElapsedTimeAsString()
                
                cell.userImage = UIImage(named: "User-64")
                if let pictureURL = request.user?.imageUrl {
                    NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                        guard error == nil else {
                            print(error!)
                            return
                        }
                        if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryRequestTableViewCell? {
                            cellToUpdate.userImage = image
                        }
                    })
                }
            }
            
            return cell
            
        } else {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "ResponseCell", for: indexPath) as! HistoryResponseTableViewCell
            
            let response = history.responses[indexPath.row - 1]
                //move bunch of view stuff to the view controller
                
            let responderName = response.responder?.firstName ?? "NAME"
            let price = response.priceInDollarFormat
            
            cell.messageLabel.text = "\(responderName) made an offer for \(price)"
            
            if let responseStatus = response.responseStatus {
                switch responseStatus {
                case .closed:
                    cell.stateColor = UIColor.nbRed
                    cell.state = "CLOSED"
                case .accepted:
                    //does it ever get here?
                    cell.stateColor = UIColor.nbGreen
                    cell.state = "ACCEPTED"
                case .pending:
                    if let sellerStatus = response.sellerStatus {
                        if sellerStatus != .accepted {
                            cell.stateColor = UIColor.nbYellow
                            cell.state = "SELLER CONFIRM"
                        }
                        else {
                            cell.stateColor = UIColor.nbGreen
                            cell.state = "OPEN"
                        }
                    }
                    else {
                        cell.stateColor = UIColor.gray
                        cell.state = "UNKNOWN"
                    }
                }
            }
            else {
                cell.stateColor = UIColor.gray
                cell.state = "UNKNOWN"
            }

            cell.time = response.getElapsedTimeAsString()
            
            cell.userImage = UIImage(named: "User-64")
            if let pictureURL = response.responder?.imageUrl {
                NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    if let cellToUpdate = historyVC.tableView?.cellForRow(at: indexPath) as! HistoryResponseTableViewCell? {
                        cellToUpdate.userImage = image
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
            let response = history.responses[(indexPath as NSIndexPath).row - 1]
            //if the response has been closed, don't allow accept/decline actions
            if (response.responseStatus?.rawValue != "CLOSED") {
                print(response)
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
            }
        
            return alertController
        }
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
   
            guard let requestDetailVC = storyboard.instantiateViewController(
                withIdentifier: "EditRequestTableViewController") as? EditRequestTableViewController else {
                    assert(false, "Misnamed view controller")
                    return UIViewController()
            }
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
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                print("Edit request button pressed")
                //go to edit request page
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let requestDetailVC = storyboard.instantiateViewController(
                    withIdentifier: "EditRequestTableViewController") as? EditRequestTableViewController else {
                        assert(false, "Misnamed view controller")
                        return
                }
                requestDetailVC.request = history.request
                requestDetailVC.delegate = historyVC
                historyVC.navigationController?.pushViewController(requestDetailVC, animated: true)
            }
            edit.backgroundColor = UIColor.nbBlue


            return [delete, edit]
        }
        else {
            let response = history.responses[(indexPath as NSIndexPath).row - 1]
            if (response.responseStatus?.rawValue != "CLOSED") {
                let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                    print("accept button tapped")
                    
                    historyVC.accepted(response)
                    
                    historyVC.tableView.isEditing = false
                }
                accept.backgroundColor = UIColor.nbBlue
                
                let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
                    print("decline button tapped")
                    
                    historyVC.declined(response)
                    
                    historyVC.tableView.isEditing = false
                }
                decline.backgroundColor = UIColor.nbRed
                
                return [decline, accept]
            } else {
                return []
            }
        }
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        if indexPath.row != 0 {
            let response = history.responses[(indexPath as NSIndexPath).row - 1]
            if (response.responseStatus?.rawValue == "CLOSED") {
                return false
            }
        }
        return true
    }
    
}
