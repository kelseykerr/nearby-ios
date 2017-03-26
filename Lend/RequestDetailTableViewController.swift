//
//  RequestDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/23/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol RequestDetailTableViewDelegate: class {
    
    //request
    
    func edited(_ request: NBRequest?)
    
    func closed(_ request: NBRequest?)
    
    //response

    func offered(_ request: NBResponse?)
    
}

enum RequestDetailTableViewMode {
    case buyer
    case seller
    case none
}

class RequestDetailTableViewController: UITableViewController {

    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var saveButton: UIButton!
    
    weak var delegate: RequestDetailTableViewDelegate?
    var request: NBRequest?
    var mode: RequestDetailTableViewMode = .none
    
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
    
    var isMyRequest: Bool {
        get {
            return request?.isMyRequest() ?? false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        if let request = request {
            loadFields(request: request)

            if mode == .buyer {
                self.saveButton.setTitle("Close", for: UIControlState.normal)
                self.saveButton.backgroundColor = UIColor.nbRed
            }
            else if mode == .none {
                self.saveButton.isHidden = true
            }
        }
    }
    
    func loadFields(request: NBRequest) {
        itemName = request.itemName
        desc = request.desc
    }
    
    @IBAction func respondButtonPressed(_ sender: UIButton) {
        if mode == .buyer {
            print("close button pressed")
            delegate?.closed(request)
            
            self.navigationController?.popViewController(animated: true)
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

extension RequestDetailTableViewController: NewRequestTableViewDelegate {
    
    func saved(_ request: NBRequest?) {
        delegate?.edited(request)
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelled() {
    }
    
}

extension RequestDetailTableViewController: NewResponseTableViewDelegate {
    
    func saved(_ response: NBResponse?) {
        delegate?.offered(response)
        self.navigationController?.popViewController(animated: true)
    }
    
}
