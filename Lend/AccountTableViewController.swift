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
import MessageUI

class AccountTableViewController: UITableViewController, LoginViewDelegate {
    
    var user: NBUser?

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var versionLabel: UILabel!
    
    var cleared = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
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
        
        let city = user?.city ?? "<city>"
        let state = user?.state ?? "<state>"
        let joinDate = (user?.joinDate) ?? "<join date>"
        self.infoLabel.text = "\(city), \(state) • Joined \(joinDate)"
        

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if indexPath.section == 1 && indexPath.row == 0 {
            sendEmail()
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        NewAccountManager.sharedInstance.doLogout(self) { error in
            // don't really need this?
        }
        
        showOAuthLoginView()
        
        UserDataManager.sharedInstace.clear()
    }
}

extension AccountTableViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail() {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([])
        mailVC.setSubject("Try Nearby")
        mailVC.setMessageBody("Nearby is a mobile app that just launched in Washington, DC. Are you looking to borrow or buy something? Do you want to make money from stuff you have sitting around? Learn more at http://thenearbyapp.com!\n\nGoogle Play Store: https://play.google.com/store/apps/details?id=iuxta.nearby\n\nApp Store: https://itunes.apple.com/us/app/nearby-share-sell-borrow/id1223745552", isHTML: false)
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
