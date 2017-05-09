//
//  HistoryFilterTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 5/6/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit


protocol HistoryFilterTableViewDelegate: class {
    
    func filtered(filter: HistoryFilter)
    
    func filterCancelled()
}

class HistoryFilterTableViewController: UITableViewController {

    @IBOutlet weak var includeTransactionSwitch: UISwitch!
    @IBOutlet weak var includeRequestSwitch: UISwitch!
    @IBOutlet weak var includeOfferSwitch: UISwitch!
    @IBOutlet weak var includeOpenSwitch: UISwitch!
    @IBOutlet weak var includeClosedSwitch: UISwitch!
    @IBOutlet weak var searchButton: UIButton!
    
    weak var delegate: HistoryFilterTableViewDelegate?
    
    var filter: HistoryFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.layer.cornerRadius = searchButton.frame.size.height / 16
        searchButton.clipsToBounds = true
        
        loadInitialData()
    }
    
    func loadInitialData() {
        if let filter = filter {
            includeTransactionSwitch.setOn(filter.includeTransaction, animated: false)
            includeRequestSwitch.setOn(filter.includeRequest, animated: false)
            includeOfferSwitch.setOn(filter.includeOffer, animated: false)
            includeOpenSwitch.setOn(filter.includeOpen, animated: false)
            includeClosedSwitch.setOn(filter.includeClosed, animated: false)
        }
    }
    
    func saveData() -> HistoryFilter {
        let newFilter = HistoryFilter()
        newFilter.includeTransaction = includeTransactionSwitch.isOn
        newFilter.includeRequest = includeRequestSwitch.isOn
        newFilter.includeOffer = includeOfferSwitch.isOn
        newFilter.includeOpen = includeOpenSwitch.isOn
        newFilter.includeClosed = includeClosedSwitch.isOn
        return newFilter
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        let newFilter = saveData()
        delegate?.filtered(filter: newFilter)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.filterCancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
}
