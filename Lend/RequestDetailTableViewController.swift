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

    func offered(_ response: NBResponse?)
    
}

enum RequestDetailTableViewMode {
    case buyer
    case seller
    case none
}

class RequestDetailTableViewController: UITableViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    weak var delegate: RequestDetailTableViewDelegate?
    
    var request: NBRequest?
    var mode: RequestDetailTableViewMode = .none

    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
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
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        flagButton.layer.cornerRadius = flagButton.frame.size.height / 16
        flagButton.clipsToBounds = true
        
        switch mode {
        case .buyer:
            self.saveButton.setTitle("Close", for: UIControlState.normal)
            self.saveButton.backgroundColor = UIColor.nbRed
            
            self.saveButton.isHidden = false
            self.flagButton.isHidden = true
        case .seller:
            self.saveButton.setTitle("Respond", for: UIControlState.normal)
            self.saveButton.backgroundColor = UIColor.nbTurquoise
            
            self.flagButton.setTitle("Flag Request", for: UIControlState.normal)
            self.flagButton.backgroundColor = UIColor.nbRed
            
            self.saveButton.isHidden = false
            self.flagButton.isHidden = false
        case .none:
            self.saveButton.isHidden = true
            self.flagButton.isHidden = true
        }
        
        if let request = request {
            loadFields(request: request)
        }
    }
    
    func showAlertMessage(message: String) {
        let alert = Utils.createErrorAlert(errorMessage: message)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadFields(request: NBRequest) {
        name = request.user?.fullName ?? "<NAME>"
        itemName = request.itemName ?? "<ITEM>"
        desc = request.desc ?? "<DESCRIPTION>"
        rent = request.rental ?? false
        
        if let pictureUrl = request.user?.imageUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureUrl, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                self.userImageView.image = image
            })
        }
    }
    
    @IBAction func respondButtonPressed(_ sender: UIButton) {
        switch mode {
        case .buyer:
            print("close button pressed")
            delegate?.closed(request)
            self.navigationController?.popViewController(animated: true)
        case .seller:
            UserManager.sharedInstance.getUser { user in
                guard user.hasAllRequiredFields() else {
                    self.showAlertMessage(message: "You must finish filling out your profile before you can make offers")
                    return
                }
                
                guard let canRespond = user.canRespond, canRespond else {
                    self.showAlertMessage(message: "You must add bank account information before you can make offers")
                    return
                }
                
                guard let navVC = UIStoryboard.getViewController(identifier: "NewResponseNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
                }
                let responseVC = navVC.childViewControllers[0] as! NewResponseTableViewController
                responseVC.delegate = self
                responseVC.request = self.request
                self.present(navVC, animated: true, completion: nil)
            }
        case .none:
            print("should never see this")
        }
    }
    
    @IBAction func flagButtonPressed(_ sender: UIButton) {
        switch mode {
        case .buyer:
            print("should never see this")
        case .seller:
            guard let navVC = UIStoryboard.getViewController(identifier: "FlagNavigationController") as? UINavigationController else {
                assert(false, "Misnamed view controller")
                return
            }
            let flagVC = navVC.childViewControllers[0] as! FlagTableViewController
            let requestId = request?.id ?? "-999"
            flagVC.mode = .request(requestId)
            self.present(navVC, animated: true, completion: nil)
        case .none:
            print("should never see this")
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
