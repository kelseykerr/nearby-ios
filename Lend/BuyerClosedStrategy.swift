//
//  BuyerClosedStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/24/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import SwiftyJSON


class BuyerClosedStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        cell.exchangeTimeLabel.isHidden = true
        cell.exchangeLocationLabel.isHidden = true
        let item = history.request?.itemName ?? "ITEM"
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let start = CGPoint.init(x: 5, y: 0)
        let end = CGPoint.init(x:5, y:100)
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 7
        line.lineJoin = kCALineJoinRound
        cell.layer.addSublayer(line)
        cell.messageLabel.text = "Requested a \(item)"
        
        cell.historyStateLabel.backgroundColor = UIColor.nbRed
        cell.historyStateLabel.text = " CLOSED "
        
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
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let requestDetailVC = storyboard.instantiateViewController(
            withIdentifier: "RequestDetailTableViewController") as? RequestDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return UIViewController()
        }
        requestDetailVC.request = history.request
        requestDetailVC.mode = .none
        return requestDetailVC

    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        
        return []
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return false
    }
    
}
