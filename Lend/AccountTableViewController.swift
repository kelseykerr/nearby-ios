//
//  AccountTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/18/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class AccountTableViewController: UITableViewController, LoginViewDelegate {
    
    var user: NBUser?

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var cityStateZipLabel: UILabel!
    @IBOutlet var userIdLabel: UILabel!
//    @IBOutlet var readyLabel: UILabel!

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var versionLabel: UILabel!
    
    var cleared = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
//        readyLabel.layer.cornerRadius = readyLabel.frame.size.height / 8
//        readyLabel.clipsToBounds = true
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        self.versionLabel.text = "©2016-17 Iuxta, Inc. v\(version) (\(build))"
        
        if cleared {
            loadInitialData()
            cleared = false
        }
        
        //likely not where this should be
        let token = FIRInstanceID.instanceID().token()!
        NBUser.editFcmToken(token) { error in
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if cleared {
            loadInitialData()
            cleared = false
        }
    }
    
    override func clear() {
        print("Account View Cleared")
        user = nil
        self.nameLabel.text = "Full Name"
        cleared = true
    }
    
    func loadInitialData() {
        if (!NewAccountManager.sharedInstance.hasOAuthToken()) {
            showOAuthLoginView()
            return
        }
        
        loadUser()
    }
    
    func showOAuthLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let loginVC = storyboard.instantiateViewController(
            withIdentifier: "LoginViewController") as? LoginViewController else {
                assert(false, "Misnamed view controller")
                return
        }
        loginVC.delegate = self
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func didTapLoginButton() {
        self.dismiss(animated: false) {
            self.loadUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        }
        
        super.viewWillAppear(animated)
    }
    
    // MARK - Table View
    func loadCells() {
        self.nameLabel.text = user?.fullName ?? "<name>"
//        self.addressLabel.text = user?.address ?? "<addess>"
//        let city = user?.city ?? "<city>"
//        let state = user?.state ?? "<state>"
//        let zip = user?.zip ?? "<zip>"
//        self.cityStateZipLabel.text = "\(city), \(state) \(zip)"
        
//        let ready = user?.canRequest
//        self.readyLabel.text = "Ready"
//        self.readyLabel.backgroundColor = UIColor.nbRed
        
//        if let pictureUrl = user?.pictureUrl {
        if let pictureUrl = user?.imageUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureUrl, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                self.userImageView.image = image
            })
        }
    }

    func loadUser() {
        UserManager.sharedInstance.getUser { fetchedUser in
            UserManager.sharedInstance.validateProfile(vc: self)
            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }

            self.user = fetchedUser
            self.loadCells()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushProfileViewController" {
            let profileVC = segue.destination as! ProfileTableViewController
            profileVC.user = self.user
        }
    }
    
    func refresh(_ sender: AnyObject) {
//        nextPageURLString = nil // so it doesn't try to append the results
        NearbyAPIManager.sharedInstance.clearCache()
        loadUser()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        NewAccountManager.sharedInstance.doLogout(self) { error in
            // don't really need this?
        }
        
        showOAuthLoginView()
        
        UserDataManager.sharedInstace.clear()
    }
}
