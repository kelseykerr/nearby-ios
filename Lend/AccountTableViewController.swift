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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.emailLabel.text = user?.email ?? "<email>"
        self.phoneLabel.text = user?.phone ?? "<phone>"
        self.addressLabel.text = user?.address ?? "<addess>"
//        self.cityStateZipLabel.text = user?.city ?? "<city>, <state> <zip>"
        let city = user?.city ?? "<city>"
        let state = user?.state ?? "<state>"
        let zip = user?.zip ?? "<zip>"
        self.cityStateZipLabel.text = "\(city), \(state) \(zip)"
        self.userIdLabel.text = user?.userId ?? "<user id>"
    }
    
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
            
            print(self.user?.toString())
            self.loadCells()
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
