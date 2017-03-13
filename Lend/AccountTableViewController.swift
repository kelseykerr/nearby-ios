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

class AccountTableViewController: UITableViewController, LoginViewDelegate {
    
    var user: NBUser?

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var cityStateZipLabel: UILabel!
    @IBOutlet var userIdLabel: UILabel!
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        
        self.versionLabel.text = "©2016-17 Iuxta, Inc. v\(version) (\(build))"
            
        loadInitialData()
    }
    
    func loadInitialData() {
        if (!AccountManager.sharedInstance.hasOAuthToken()) {
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
        self.addressLabel.text = user?.address ?? "<addess>"
        let city = user?.city ?? "<city>"
        let state = user?.state ?? "<state>"
        let zip = user?.zip ?? "<zip>"
        self.cityStateZipLabel.text = "\(city), \(state) \(zip)"
        
        if let pictureUrl = user?.pictureUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureUrl, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                self.userImageView.image = image
            })
        }
        else if user?.firstName == "Demo" {
            self.userImageView.image = UIImage(named: "IMG_1426")
        }
        else {
            self.userImageView.image = UIImage(named: "User-64")
        }
        
        
    }

    func loadUser() {
        UserManager.sharedInstance.getUser { fetchedUser in

            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }

            self.user = fetchedUser
            self.loadCells()
        }
    }
    
    /*
    func loadUser() {
        NBUser.fetchSelf { result in
            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let fetchedUser = result.value else {
                print("no value was returned")
                return
            }
            
            self.user = fetchedUser
            
//            print(self.user?.toString())
            
            self.loadCells()
        }
    }
     */
    
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
        let manager = FBSDKLoginManager()
        manager.logOut()
        
        showOAuthLoginView()
    }
}
