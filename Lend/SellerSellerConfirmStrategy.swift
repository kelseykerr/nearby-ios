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
        let inventoryRequest = history.request?.type == RequestType.selling.rawValue || history.request?.type == RequestType.loaning.rawValue
        let request = history.request
        let item = history.request?.itemName ?? "ITEM"
        if indexPath.row == 0 {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
            if inventoryRequest {
                let action = (request?.type == RequestType.selling.rawValue) ? "Selling" : "Offering to loan out"
                cell.message = "\(action) a \(item)"
                cell.stateColor = UIColor.nbGreen
                cell.state = "OPEN"
            } else {
                let name = history.request?.user?.firstName ?? "NAME"
                let price = history.responses[0].priceInDollarFormat
                cell.message = "Offered a \(item) to \(name) for \(price)"
                
                cell.stateColor = UIColor.nbYellow
                cell.state = "PENDING YOUR APPROVAL"
                
                cell.time = history.request?.getElapsedTimeAsString()
  
            }
            cell.userImage = UIImage(named: "User-64")
            if let pictureURL = request?.user?.imageUrl {
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
            cell.time = history.request?.getElapsedTimeAsString()
            return cell
        } else {
            let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "ResponseCell", for: indexPath) as! HistoryResponseTableViewCell
            let response = history.responses[indexPath.row - 1]
            let name: String = response.responder?.firstName ?? "NAME"
            let price = response.priceInDollarFormat
            cell.messageLabel?.text = "\(name) made an offer for \(price)"
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
            if response.responseStatus == ResponseStatus.closed {
                cell.stateColor = UIColor.nbRed
                cell.state = "CLOSED"
            } else if response.buyerStatus == BuyerStatus.accepted {
                cell.stateColor = UIColor.nbYellow
                cell.state = "PENDING YOUR APPROVAL"
            } else if response.sellerStatus == SellerStatus.accepted {
                cell.stateColor = UIColor.nbYellow
                cell.state = "PENDING BUYER APPROVAL"
            }
            cell.time = response.getElapsedTimeAsString()
            return cell
        }
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
         let inventoryRequest = history.request?.type == RequestType.selling.rawValue || history.request?.type == RequestType.loaning.rawValue
        if history.responses.count > 0 && !inventoryRequest {
            let response = history.responses[0]
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let responseDetailVC = storyboard.instantiateViewController(
                withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                    assert(false, "Misnamed view controller")
                    return UIViewController()
            }
            responseDetailVC.mode = history.request?.isMyRequest() ?? false ? .requester : .responder
            responseDetailVC.delegate = historyVC
            responseDetailVC.request = history.request
            responseDetailVC.response = response
            return responseDetailVC
        } else  {
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
                
            } else {
                let response = history.responses[indexPath.row - 1]
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let responseDetailVC = storyboard.instantiateViewController(
                    withIdentifier: "ResponseDetailTableViewController") as? ResponseDetailTableViewController else {
                        assert(false, "Misnamed view controller")
                        return UIViewController()
                }
                responseDetailVC.mode = history.request?.isMyRequest() ?? false ? .requester : .responder
                responseDetailVC.delegate = historyVC
                responseDetailVC.request = history.request
                responseDetailVC.response = response
                return responseDetailVC
            }
        }

    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        /*let detail = UITableViewRowAction(style: .normal, title: "Detail") { action, index in
            print("detail button tapped")
        }
        detail.backgroundColor = UIColor.lightGray
        
        return [detail]*/
        return []
    }

    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return false
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
