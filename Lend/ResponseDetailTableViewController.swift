//
//  ResponseDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/12/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

class ResponseDetailTableViewController: UITableViewController {
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
