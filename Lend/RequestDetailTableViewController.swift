//
//  RequestDetailTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/23/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import NYTPhotoViewer


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

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: RequestDetailTableViewDelegate?
    
    var request: NBRequest?
    var mode: RequestDetailTableViewMode = .none
    var photos: [NBPhoto] = []
    
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
    
    var rent: RequestType {
        get {
            //this can be better, simply make an initializer for enum to do this.... later
            if let rental = rentLabel.text {
                switch rental {
                case "borrow":
                    return RequestType.renting
                case "buy":
                    return RequestType.buying
                case "loan":
                    return RequestType.loaning
                case "sell":
                    return RequestType.selling
                default:
                    return RequestType.none
                }
            }
            return RequestType.none
        }
        set {
            if newValue == RequestType.renting {
                rentLabel.text = "borrow"
            }
            else {
                rentLabel.text = newValue.rawValue.replacingOccurrences(of: "ing", with: "")
            }
        }
    }
    
    var isMyRequest: Bool {
        get {
            return request?.isMyRequest() ?? false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .buyer:
            self.saveButton.setTitle("Close", for: UIControlState.normal)
//            self.saveButton.backgroundColor = UIColor.nbRed
            
            self.saveButton.isHidden = false
            self.navigationItem.rightBarButtonItem = nil
        case .seller:
            self.saveButton.setTitle("Respond", for: UIControlState.normal)
//            self.saveButton.backgroundColor = UIColor.nbTurquoise
            
            self.saveButton.isHidden = false
        case .none:
            self.saveButton.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
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
        itemName = request.itemName ?? "<ITEM>"
        desc = request.desc ?? "<DESCRIPTION>"
        rent = request.requestType
        
        loadPhotos(photoStringArray: request.photos)
    }
    
    func loadPhotos(photoStringArray: [String]) {
        for photoString in photoStringArray {
            let pictureURL = "https://s3.amazonaws.com/nearbyappphotos/\(photoString)"
            print(pictureURL)
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                print("done")
                guard error == nil else {
                    print(error!)
                    return
                }
                let photo = NBPhoto(image: image)
                self.photos.append(photo)
                self.collectionView.reloadData()
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
    
    @IBAction func actionButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let flagAction = UIAlertAction(title: "Flag Post", style: .destructive) { action in
            guard let navVC = UIStoryboard.getViewController(identifier: "FlagNavigationController") as? UINavigationController else {
                assert(false, "Misnamed view controller")
                return
            }
            let flagVC = navVC.childViewControllers[0] as! FlagTableViewController
            let requestId = self.request?.id ?? "-999"
            flagVC.mode = .request(requestId)
            self.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(flagAction)
        
        let blockAction = UIAlertAction(title: "Block User", style: .destructive) { action in
            guard let navVC = UIStoryboard.getViewController(identifier: "FlagNavigationController") as? UINavigationController else {
                assert(false, "Misnamed view controller")
                return
            }
            let flagVC = navVC.childViewControllers[0] as! FlagTableViewController
            let userId = self.request?.user?.id ?? "-999"
            flagVC.mode = .user(userId)
            self.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(blockAction)
        
        self.present(alertController, animated: true) {
        }
    }
}

extension RequestDetailTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell",
                                                      for: indexPath) as! ImageCollectionViewCell
        
//        cell.backgroundColor = UIColor.black
        
        cell.photoImageView.image = photos[indexPath.row].image
        // Configure the cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let photosVC = NYTPhotosViewController(photos: photos, initialPhoto: photo)
        self.present(photosVC, animated: true, completion: nil)
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
