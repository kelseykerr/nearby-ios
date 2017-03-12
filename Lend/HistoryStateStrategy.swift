//
//  HistoryStateStrategy.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


protocol HistoryStateStrategy: class {
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]?
    
}
