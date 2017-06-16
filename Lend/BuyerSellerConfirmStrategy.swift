//
//  BuyerSellerConfirmStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class BuyerSellerConfirmStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
            let inventoryRequest = history.request?.type == RequestType.selling.rawValue || history.request?.type == RequestType.loaning.rawValue
            if inventoryRequest {
                if let request = history.request {
                    let item = request.itemName ?? "ITEM"
                    let action = request.type == RequestType.loaning.rawValue ? "borrow" : "buy"
                    let name = history.request?.user?.shortName ?? "NAME"
                    
                    cell.message = "Requested to \(action) a \(item) from \(name)"
                    
                    cell.stateColor = UIColor.nbYellow
                    cell.state = "SELLER CONFIRM"
                    
                    cell.time = history.request?.getElapsedTimeAsString()
                }

            } else {
                if let request = history.request {
                    let item = request.itemName ?? "ITEM"
                    let action = request.type == RequestType.renting.rawValue ? "borrow" : "buy"
                    cell.message = "Requested to \(action) a \(item)"
                    
                    cell.stateColor = UIColor.nbGreen
                    cell.state = "OPEN"
                    
                    cell.time = request.getElapsedTimeAsString()
                }

            }
            cell.userImage = UIImage(named: "User-64")
            if let pictureURL = history.request?.user?.imageUrl {
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
                            cell.state = "AWAITING SELLER APPROVAL"
                        } else {
                            cell.stateColor = UIColor.nbYellow
                            cell.state = "AWAITING YOUR APPROVAL"
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
        let alertController = UIAlertController(title: "SellerConfirm Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let responseDetailVC = storyboard.instantiateViewController(
            withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return UIViewController()
        }
        responseDetailVC.response = history.responses[0]
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
    
    func heightForRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        }
        else {
            return 60
        }
    }
    
}
