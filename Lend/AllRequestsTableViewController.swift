//
//  AllRequestsTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class AllRequestsTableViewController: UITableViewController, LoginViewDelegate {
    
    var requests = [NBRequest]()
    var nextPageURLString: String?
    var isLoading = false
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInitialData()
    }
    
    
    func loadInitialData() {
        if (!AccountManager.sharedInstance.hasOAuthToken()) {
            showOAuthLoginView()
            return
        }
        
        self.loadRequests(37.5789, longitude: -122.3451, radius: 1000)
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
//            guard let authURL = GitHubAPIManager.sharedInstance.URLToStartOAuth2Login() else {
//                return
//            }
// TODO: show web page
            
            self.loadRequests(37.5789, longitude: -122.3451, radius: 1000)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
//            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
//            self.dateFormatter.dateStyle = .ShortStyle
//            self.dateFormatter.timeStyle = .LongStyle
        }
        
        super.viewWillAppear(animated)
    }
    
    // MARK - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
        
        let request = requests[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = request.itemName
        cell.detailTextLabel?.text = request.desc
        
//        if !isLoading {
//            let rowsLoaded = requests.count
//            let rowsRemaining = rowsLoaded - indexPath.row
//            let rowsToLoadFromBottom = 5
//            if rowsRemaining <= rowsToLoadFromBottom {
//                if let nextPage = nextPageURLString {
//                    self.loadRequests(nextPage)
//                }
//            }
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(requests[(indexPath as NSIndexPath).row].toString())
        
        let req = requests[(indexPath as NSIndexPath).row]
        NBRequest.editRequest(req) { error in
        }
    }
    
    
    func loadRequests(_ latitude: Double, longitude: Double, radius: Double) {
        NBRequest.fetchRequests(latitude, longitude: longitude, radius: Converter.metersToMiles(radius)) { result in
            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let fetchedRequests = result.value else {
                print("no requests fetched")
                return
            }
            self.requests = fetchedRequests
            
            self.tableView.reloadData()
        }
    }
    
    func refresh(_ sender: AnyObject) {
//        nextPageURLString = nil // so it doesn't try to append the results
        NearbyAPIManager.sharedInstance.clearCache()
        self.loadRequests(37.5789, longitude: -122.3451, radius: 1000)
    }
    
}
