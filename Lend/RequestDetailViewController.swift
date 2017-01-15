//
//  RequestDetailViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/23/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class RequestDetailTableViewController: UITableViewController {

    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    var request: NBRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.itemNameLabel.text = request?.itemName
        self.descriptionTextView.text = request?.desc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PopoverNewResponseViewController" {
            print(sender)
            
            let newResponseVC = segue.destination.childViewControllers[0] as! NewResponseTableViewController
            newResponseVC.delegate = self
        }
    }
    
}

extension RequestDetailTableViewController: NewResponseTableViewDelegate {
    func saved(_ response: NBResponse) {
        print("saved 2")
    }
    
    func cancelled() {
        print("cancelled 2")
    }

}
