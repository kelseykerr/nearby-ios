//
//  SellerExchangeStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class SellerExchangeStrategy: HistoryStateStrategy {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        let cell = historyVC.tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HistoryRequestTableViewCell
        
            let name: String = history.request?.user?.firstName ?? "NAME"
            let item = history.request?.itemName ?? "ITEM"
            cell.messageLabel?.text = "You are meeting \(name) to exchange \(item)."
        
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
//            let generatorVC = (navVC.childViewControllers[0] as! QRGeneratorViewController)
//            generatorVC.delegate = self
//            generatorVC.transaction = self.getTransaction(indexPath.section)
//            self.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(exchangeAction)
        
        return alertController
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        let detail = UITableViewRowAction(style: .normal, title: "Detail") { action, index in
            print("detail button tapped")
        }
        detail.backgroundColor = UIColor.lightGray
        
        return [detail]
    }
    
}
