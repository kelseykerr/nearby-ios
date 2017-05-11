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
        cell.exchangeTimeLabel.isHidden = true
        cell.exchangeLocationLabel.isHidden = true
        let name = history.request?.user?.shortName ?? "NAME"
        let item = history.request?.itemName ?? "ITEM"
        let price = history.responses[0].priceInDollarFormat
        cell.messageLabel.text = "Offered a \(item) to \(name) for \(price)"

        
        cell.historyStateLabel.backgroundColor = UIColor.energy
        cell.historyStateLabel.textColor = UIColor.white
        cell.historyStateLabel.text = " PENDING YOUR APPROVAL "
        cell.timeLabel.text = history.request?.getElapsedTimeAsString()
        
        //add white line so that transaction card doesn't place yellow line on scroll
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let start = CGPoint.init(x: 5, y: 1)
        let end = CGPoint.init(x:5, y:99)
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 7
        line.lineJoin = kCALineJoinRound
        cell.layer.addSublayer(line)
        
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
                return UIViewController()
        }
        let response = history.responses[0]
        responseDetailVC.mode = .seller
        responseDetailVC.delegate = historyVC
        responseDetailVC.response = response
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
