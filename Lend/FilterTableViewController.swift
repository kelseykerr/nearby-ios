//
//  FilterTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 10/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol FilterTableViewDelegate: class {
    
    func searched() // need to likely send something back...
    
    func cancelled()
}

class FilterTableViewController: UITableViewController {
    
    weak var delegate: FilterTableViewDelegate?
    
    var filter: SearchFilter?
    
    @IBOutlet var includeMyRequestSwitch: UISwitch!
    @IBOutlet var includeExpiredRequestSwitch: UISwitch!
    @IBOutlet var sortRequestByDateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInitialData()
    }
    
    func loadInitialData() {
        if let filter = filter {
            includeMyRequestSwitch.setOn(filter.includeMyRequest, animated: false)
            includeExpiredRequestSwitch.setOn(filter.includeExpiredRequest, animated: false)
            sortRequestByDateSwitch.setOn(filter.sortRequestByDate, animated: false)
        }
    }

    @IBAction func includeMyRequestChanged(_ sender: UISwitch) {
//        filter?.includeMyRequest = includeMyRequestSwitch.isOn
    }
    
    @IBAction func includeExpiredRequestChanged(_ sender: UISwitch) {
//        filter?.includeExpiredRequest = includeExpiredRequestSwitch.isOn
    }
    
    @IBAction func sortRequestByDateChanged(_ sender: UISwitch) {
//        filter?.sortRequestByDate = sortRequestByDateSwitch.isOn
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        print("FilterTableView::searchButtonPressed")
        
        if let filter = filter {
            filter.includeMyRequest = includeMyRequestSwitch.isOn
            filter.includeExpiredRequest = includeExpiredRequestSwitch.isOn
            filter.sortRequestByDate = sortRequestByDateSwitch.isOn
        }
        
        delegate?.searched()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("FilterTableView::cancelButtonPressed")
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
}
