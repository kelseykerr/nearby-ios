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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var versionLabel: UILabel!
    
    let emailIndexPath = IndexPath(row: 0, section: 1)
    let rateIndexPath = IndexPath(row: 1, section: 1)

    var user: NBUser?
    
    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
    
    var info: String? {
        get {
            return infoLabel.text
        }
        set {
            infoLabel.text = newValue
        }
    }
    
    var userImage: UIImage? {
        get {
            return userImageView.image
        }
        set {
            userImageView.image = newValue
        }
    }
    
    var versionBuild: String? {
        get {
            return versionLabel.text
        }
        set {
            versionLabel.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.clear), name: NSNotification.Name(rawValue: "ClearUser"), object: nil)
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        versionBuild = "©2016-17 Iuxta, Inc. v\(version) (\(build))"
        
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            
            let bounds = CGRect(x: 0, y: 100, width: 1, height: 1) // hides the indicator
            self.refreshControl?.bounds = bounds
            
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        }
        
        super.viewWillAppear(animated)
    }
    
    func clear() {
        //need a better default like facebook
        print("Account View Cleared")
        user = nil
        userImage = nil
        name = "Full Name"
        info = "Location"
    }
    
    func loadInitialData() {
        if (!NewAccountManager.sharedInstance.hasOAuthToken()) {
            showOAuthLoginView()
            return
        }
        
        loadUser()
    }
    
    func showOAuthLoginView() {
        let loginVC = UIStoryboard.getLoginVC()
        loginVC.delegate = self
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func didTapLoginButton() {
        self.dismiss(animated: false) {
            if let token = FIRInstanceID.instanceID().token() {
                NBUser.editFcmToken(token) { error in
                }
            }
            
            self.loadUser()
        }
    }
        
    // MARK - Table View
    func loadCells() {
        if let user = user {
            name = user.fullName ?? ""
            
            if !(user.city ?? "").isEmpty && !(user.state ?? "").isEmpty {
                info = "\(user.city!), \(user.state!)"
            } else if !(user.city ?? "").isEmpty {
                info = user.city!
            } else if !(user.state ?? "").isEmpty {
                info = user.state!
            } else {
                info = ""
            }
            
            if let pictureUrl = user.imageUrl {
                NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureUrl, completionHandler: { (image, error) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    self.userImage = image
                })
            }
        }
    }

    func loadUser() {
        let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Loading")
        
        UserManager.sharedInstance.fetchUser { fetchedUser in
            
            loadingNotification.hide(animated: true)
            
            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            
            UserManager.sharedInstance.validateProfile(vc: self)
            
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
        NearbyAPIManager.sharedInstance.clearCache()
        loadUser()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == emailIndexPath {
            sendEmail()
        }
        else if indexPath == rateIndexPath {
            rate()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        NewAccountManager.sharedInstance.doLogout(self) { error in
            // don't really need this?
        }
        
        showOAuthLoginView()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClearUser"), object: nil)
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
    
    func rate() {
        if let appURL = URL(string: "itms-apps://itunes.apple.com/app/id1223745552") {
            UIApplication.shared.openURL(appURL)
        }
    }
    
}
