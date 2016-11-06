//
//  TransactionTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 10/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class TransactionTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // each cell displays something different on this?
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)
            
        if let request = getRequest((indexPath as NSIndexPath).section) {
            cell.textLabel?.text = request.itemName
            cell.detailTextLabel?.text = request.desc
        }
            
        
        return cell
    }
    
}
