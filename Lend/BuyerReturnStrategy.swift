//
//  BuyerReturnStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class BuyerReturnStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        
        let sellerName = history.responses[indexPath.row].seller?.shortName ?? "NAME"
        let item = history.request?.itemName ?? "ITEM"
        
        cell.messageLabel.text = "Borrowing a \(item) from \(sellerName)"
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let start = CGPoint.init(x: 5, y: 0)
        let end = CGPoint.init(x:5, y:90)
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.nbYellow.cgColor
        line.lineWidth = 7
        line.lineJoin = kCALineJoinRound
        cell.layer.addSublayer(line)
/*
        let attrText = NSMutableAttributedString(string: "")
        let boldFont = UIFont.boldSystemFont(ofSize: 15)
        
        let boldYou = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldYou)
        
        attrText.append(NSMutableAttributedString(string: " are meeting "))
        
        let boldName = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldName)
        
        attrText.append(NSMutableAttributedString(string: " to return "))
        
        let boldItemName = NSMutableAttributedString(string: item, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldItemName)
        
        attrText.append(NSMutableAttributedString(string: "."))
        
        cell.messageLabel.attributedText = attrText
*/
        
        if (history.status == .buyer_overrideReturn) {
            cell.historyStateLabel.backgroundColor = UIColor.nbYellow
            cell.historyStateLabel.text = " Return Override Pending Approval "
        } else {
            cell.historyStateLabel.backgroundColor = UIColor.nbYellow
            cell.historyStateLabel.text = " AWAITING RETURN "
        }
        
        cell.timeLabel.text = history.request?.getElapsedTimeAsString()
        
        cell.userImageView.image = UIImage(named: "User-64")
        cell.setNeedsLayout()
        
        let seller = history.getResponseById(id: (history.transaction?.responseId)!)?.seller
        
        if let pictureURL = seller?.imageUrl {
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
        let alertController = UIAlertController(title: "Exchange Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let exchangeAction = UIAlertAction(title: "Exchange", style: .default) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRGeneratorNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let generatorVC = (navVC.childViewControllers[0] as! QRGeneratorViewController)
            generatorVC.delegate = historyVC
            generatorVC.transaction = history.transaction
            historyVC.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(exchangeAction)
        
        return alertController
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let transactionDetailVC = storyboard.instantiateViewController(
            withIdentifier: "TransactionDetailTableViewController") as? TransactionDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return UIViewController()
        }
        transactionDetailVC.delegate = historyVC
        transactionDetailVC.history = history
        transactionDetailVC.mode = .buyer_generate
        return transactionDetailVC
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let exchange = UITableViewRowAction(style: .normal, title: "Return") { action, index in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRGeneratorNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let generatorVC = (navVC.childViewControllers[0] as! QRGeneratorViewController)
            generatorVC.delegate = historyVC
            generatorVC.transaction = history.transaction
            historyVC.present(navVC, animated: true, completion: nil)
            
            historyVC.tableView.isEditing = false
        }
        exchange.backgroundColor = UIColor.nbTurquoise
        
        return [exchange]
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        return true
    }
    
}
