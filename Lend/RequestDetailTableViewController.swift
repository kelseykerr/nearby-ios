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
    @IBOutlet var rentLabel: UILabel!
    
    @IBOutlet var saveButton: UIButton!
    
    weak var delegate: RequestDetailTableViewDelegate?
    var request: NBRequest?
    var mode: RequestDetailTableViewMode = .none
    var alertController: UIAlertController?
    
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
    
    var rent: Bool {
        get {
            return rentLabel.text == "rent"
        }
        set {
            rentLabel.text = (newValue) ? "rent" : "buy"
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
    
    func showAlertMsg(message: String) {
        guard (self.alertController == nil) else {
            print("Alert already displayed")
            return
        }
        
        self.alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "close", style: .cancel) { (action) in
            print("Alert was cancelled")
            self.alertController=nil;
        }
        
        self.alertController!.addAction(cancelAction)
        
        self.present(self.alertController!, animated: true, completion: nil)
    }

    
    func loadFields(request: NBRequest) {
        itemName = request.itemName
        desc = request.desc
        rent = request.rental ?? false
    }
    
    @IBAction func respondButtonPressed(_ sender: UIButton) {
        if mode == .buyer {
            print("close button pressed")
            delegate?.closed(request)
            
            self.navigationController?.popViewController(animated: true)
        }
        else {
            UserManager.sharedInstance.getUser { fetchedUser in
                if (!fetchedUser.hasAllRequiredFields()) {
                    self.showAlertMsg(message: "You must finish filling out your profile before you can make offers")
                    
                } else if (!fetchedUser.canRespond!) {
                    self.showAlertMsg(message: "You must add bank account information before you can make offers")
                } else {
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
