//
//  RequestDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/23/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class RequestDetailTableViewController: UITableViewController {

    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var saveButton: UIButton!
    
    var request: NBRequest?
    var edit = false
    
    var itemName: String? {
        get {
            return itemNameLabel.text
        }
        set {
            itemNameLabel.text = newValue
        }
    }
    
    var desc: String? {
        get {
            return descriptionTextView.text
        }
        set {
            descriptionTextView.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.width / 64
        saveButton.clipsToBounds = true
        
        loadFields(request: request!)
        
        if let request = request {
            edit = request.isMyRequest()
            if edit {
                self.saveButton.setTitle("Edit", for: UIControlState.normal)
            }
        }
    }
    
    func loadFields(request: NBRequest) {
        itemName = request.itemName
        desc = request.desc
    }
    
    @IBAction func respondButtonPressed(_ sender: UIButton) {
        if edit {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "NewRequestNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let newRequestVC = (navVC.childViewControllers[0] as! NewRequestTableViewController)
//            newRequestVC.delegate = self
            newRequestVC.request = request
            self.present(navVC, animated: true, completion: nil)
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "NewResponseNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let responseVC = (navVC.childViewControllers[0] as! NewResponseTableViewController)
            responseVC.delegate = self
            responseVC.request = self.request
            self.present(navVC, animated: true, completion: nil)
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
