//
//  HomeViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/21/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Ipify
import MBProgressHUD
import DZNEmptyDataSet
import Firebase


class HomeViewController: UIViewController, LoginViewDelegate, UISearchBarDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    //@IBOutlet var reloadView: UIToolbar!
    @IBOutlet var requestButton: UIButton!
    @IBOutlet var noResultsView: UIView!
    @IBOutlet var noResultsText: UILabel!
    @IBOutlet var notAvailableText: UILabel!
    
    var requests = [NBRequest]()
    var nextPageURLString: String?
    var isLoading = false
    var dateFormatter = DateFormatter()
    
    //this works for now, but gotta change when we do redesign of views
    var frontView: UIView!

    var searchFilter = SearchFilter()
    let progressHUD = ProgressHUD(text: "Saving")
    
    var alertController: UIAlertController?
    var alertTimer: Timer?
    var remainingTime = 0
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    var cleared = true
    
    var refreshControl: UIRefreshControl? {
        get {
            if #available(iOS 10.0, *) {
                return self.tableView.refreshControl
            } else {
                return self.tableView.backgroundView as? UIRefreshControl
            }
        }
        set {
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl = newValue
            } else {
                self.tableView.backgroundView = newValue
            }
        }
    }
    
    deinit {
        if tableView != nil {
        self.tableView.emptyDataSetSource = nil
        self.tableView.emptyDataSetDelegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDataManager.sharedInstace.addClearable(self)
        /*
        UserManager.sharedInstance.getUser(completionHandler: { user in
            print("VALIDATE PROFILE***")
            print(user.tosAccepted)
            UserManager.sharedInstance.validateProfile(vc: self)
        })
         */
        if LocationManager.sharedInstance.locationAvailable() {
            print(LocationManager.sharedInstance.location)
        }
        
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        for subView in searchBar.subviews[0].subviews where subView is UITextField {
            subView.tintColor = UIColor.gray
        }
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.gray
        
        self.navigationItem.titleView = searchBar
        
        self.tableView.contentInset = UIEdgeInsetsMake(-26, 0, 0, 0)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.tableView.tableFooterView = UIView()
        
        requestButton.layer.cornerRadius = requestButton.frame.size.width / 2
        requestButton.clipsToBounds = true
        
        self.mapView.delegate = self
        self.view.bringSubview(toFront: mapView)
        self.view.bringSubview(toFront: requestButton)
//        self.view.bringSubview(toFront: noResultsText)
        self.view.bringSubview(toFront: notAvailableText)
        self.noResultsText.center = self.view.center
        self.notAvailableText.center = self.view.center

        self.frontView = mapView
        if cleared {
            loadInitialData()
            cleared = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            
//            let bounds = CGRect(x: (refreshControl?.bounds.origin.x)!, y: -26.0, width: (refreshControl?.bounds.size.width)!, height: (refreshControl?.bounds.size.height)!)
            let bounds = CGRect(x: 0, y: 100, width: 1, height: 1) // hides the indicator
            self.refreshControl?.bounds = bounds
            
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        }
        
        if cleared {
            loadInitialData()
            cleared = false
        }
        
        super.viewWillAppear(animated)
    }
    
//    override func viewDidUnload() {
//        UserDataManager.sharedInstace.removeClearable(self)
//    }
    
    override func clear() {
        print("Home View Cleared")
        requests = []
        self.tableView.reloadData()
        cleared = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFilter.searchTerm = searchBar.text!
        loadRequests()
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText == "") {
            searchFilter.searchTerm = searchBar.text!
            searchBar.endEditing(true)
            loadRequests()
            searchBar.endEditing(true)
        }
    }
    
    func loadInitialData() {
        if (!NewAccountManager.sharedInstance.hasOAuthToken()) {
            showOAuthLoginView()
            return
        }
        
        // make this better, but loading user ASAP for other use
        if !UserManager.sharedInstance.userAvailable() {
//            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
//            loadingNotification.mode = MBProgressHUDMode.indeterminate
//            loadingNotification.label.text = "Loading..."
//            loadingNotification.isUserInteractionEnabled = false
            
            UserManager.sharedInstance.fetchUser(completionHandler: { user in
//                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            })
        }
        
        let currentLocation = LocationManager.sharedInstance.location
        let radius = getRadius()
        loadRequests((currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!, radius: radius)
    }
    
    func acceptTOS(user:NBUser) -> () {
        self.progressHUD.show()
        
        NBUser.editSelf(user) { (result, error) in
            self.progressHUD.hide()
            guard error == nil else {
                let alert = Utils.createServerErrorAlert(error: error! as NSError)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let editedUser = result.value else {
                print("no value was returned")
                return
            }
            
            UserManager.sharedInstance.user = editedUser
            
        }

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
    
    func showEditProfileView() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let editProfileVC = storyboard.instantiateViewController(
            withIdentifier: "ProfileTableViewController") as? ProfileTableViewController else {
                assert(false, "Misnamed view controller")
                return
        }
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    func showHistoryView() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarNavigationController") as! UITabBarController
        vc.selectedIndex = 1
        self.present(vc, animated: true, completion: nil)
    }
    
    func didTapLoginButton() {
        self.dismiss(animated: false) {
            
            //make this a function in Utils?
            let loginCount = UserDefaults.standard.integer(forKey: "loginCount")
            let firstLogin = (loginCount == 0)
            if firstLogin {
                print("first login")
                UserDefaults.standard.set(loginCount + 1, forKey: "loginCount")
                self.showEditProfileView()
            }
        
            let currentLocation = LocationManager.sharedInstance.location
            let radius = self.getRadius()
            self.loadRequests((currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!, radius: radius)
            
            UserManager.sharedInstance.getUser(completionHandler: { user in
                UserManager.sharedInstance.validateProfile(vc: self)
            })
            
            if let token = FIRInstanceID.instanceID().token() {
                NBUser.editFcmToken(token) { error in
                }
            }

        }
    }
    
    func reloadRequests(_ latitude: Double, longitude: Double, radius: Double) {
        mapView.removeAnnotations(mapView.annotations)
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Fetching")
        
        let searchTerm = searchFilter.searchTerm
        let includeWanted = searchFilter.includeWanted
        let includeOffered = searchFilter.includeOffered
        let sort = searchFilter.sortBy
        
        NBRequest.fetchRequests(latitude, longitude: longitude, radius: Converter.metersToMiles(radius), includeWanted: includeWanted, includeOffered: includeOffered, searchTerm: searchTerm, sort: sort) { (result, error) in
            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            
            print(result)
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            guard error == nil else {
                //if error == 403, display the not available message on the screen
                print(error)
                self.requests = []
                self.tableView.reloadData()
                if (error?.code == 403) {
                    self.noResultsText.isHidden = true
                    self.notAvailableText.isHidden = false
                    self.notAvailableText.center = self.view.center
                }
                return
            }
            self.notAvailableText.isHidden = true;
            guard let fetchedRequests = result.value else {
                print("no requests fetched")
                return
            }
            if (fetchedRequests.count == 0) {
                self.noResultsText.isHidden = false;
                self.noResultsText.center = self.view.center
            } else {
                self.noResultsText.isHidden = true;
            }
            
            for req in fetchedRequests {
                print(req.toString())
            }

            self.mapView.addAnnotations(fetchedRequests)
            self.requests = fetchedRequests
            
            self.tableView.reloadData()
        }
    }

    func loadRequests(_ latitude: Double, longitude: Double, radius: Double) {
        
        mapView.removeAnnotations(mapView.annotations)
        noResultsText.isHidden = true;
        notAvailableText.isHidden = true;
        
        let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Fetching")

        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
            
        let searchTerm = searchFilter.searchTerm
        let includeWanted = searchFilter.includeWanted
        let includeOffered = searchFilter.includeOffered
        let sort = searchFilter.sortBy;
        
        NBRequest.fetchRequests(latitude, longitude: longitude, radius: Converter.metersToMiles(radius), includeWanted: includeWanted, includeOffered: includeOffered, searchTerm: searchTerm, sort: sort) { (result, error) in
            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            //hide progress spinner
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)

            //TODO: This doesn't work...we areen't ever getting server errors here, the method that uses the responseArray needs to be updated
//            guard error == nil else {
//                //TODO: if error == 403, display the not available message on the screen
//                print(error)
//                return
//            }
            guard error == nil else {
                //if error == 403, display the not available message on the screen
                print(error)
                self.requests = []
                self.tableView.reloadData()
                if (error?.code == 403) {
                    self.noResultsText.isHidden = true
                    self.notAvailableText.isHidden = false
                    self.notAvailableText.center = self.view.center
                }
                return
            }
            
            guard let fetchedRequests = result.value else {
                print("no requests fetched")
                return
            }
            self.notAvailableText.isHidden = true;
            if (fetchedRequests.count == 0) {
                self.noResultsText.isHidden = false;
                self.noResultsText.center = self.view.center
            } else {
                self.noResultsText.isHidden = true;
            }
            
            for req in fetchedRequests {
                print(req.toString())
            }
            
            self.mapView.addAnnotations(fetchedRequests)
            self.requests = fetchedRequests
            
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func listMapButtonPressed(_ sender: UIBarButtonItem) {
        searchBar.endEditing(true)
        
//this works for now, but gotta change when we do redesign of views
//        if sender.title == "List" {
        if frontView == mapView {
//            sender.title = "Map"
            sender.image = UIImage(named: "Map")
            frontView = tableView
            self.view.bringSubview(toFront: tableView)
        }
        else {
            sender.image = UIImage(named: "List")
//            sender.title = "List"
            frontView = mapView
            self.view.bringSubview(toFront: mapView)
        }
        self.view.bringSubview(toFront: requestButton)
        self.view.bringSubview(toFront: noResultsText)
        self.noResultsText.center = self.view.center
        self.view.bringSubview(toFront: notAvailableText)
        self.notAvailableText.center = self.view.center

    }
    
    /*@IBAction func redoSearchButtonPressed(_ sender: UIBarButtonItem) {
        let radius = self.getRadius()
        let center = self.getCenterCoordinate()
        
//        print(radius)
//        print(center)

        reloadRequests(center.latitude, longitude: center.longitude, radius: radius)
        self.view.bringSubview(toFront: mapView)
        self.view.bringSubview(toFront: requestButton)
    }*/
    
    func loadRequests() {
        let radius = self.getRadius()
        let center = self.getCenterCoordinate()
        
        reloadRequests(center.latitude, longitude: center.longitude, radius: radius)
    }
    
    /*
    func showRequestDetailView(req: NBRequest) {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        guard let loginVC = storyboard.instantiateViewControllerWithIdentifier(
//            "DetailNavigationViewController") as? DetailViewController else {
//                assert(false, "Misnamed view controller")
//                return
//        }
//        loginVC.delegate = self
        
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("DetailNavigationController") as! UINavigationController
        let detailVC = loginVC.viewControllers[0] as! DetailViewController
        detailVC.request = req
        loginVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushRequestDetailViewController" {
            print(sender)
            
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            let requestDetailVC = segue.destination as! RequestDetailTableViewController
            requestDetailVC.request = requests[(indexPath! as NSIndexPath).section]
            print(requestDetailVC.request?.itemName)
            print("PATH: \(indexPath?.section)")
            
//            let req: NBRequest = requests[indexPath!.row]
//            req.desc = req.desc! + " test"
//            NearbyAPIManager.sharedInstance.editRequest(req, completionHandler: { error in
//                if (error != nil) {
//                    print(error)
//                }
//                print("edited")
//            })
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
        /*if (time > 0) {
            self.alertTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        }*/
        
        self.present(self.alertController!, animated: true, completion: nil)
    }
    
    func countDown() {
        
        self.remainingTime -= 1
        if (self.remainingTime < 0) {
            self.alertTimer?.invalidate()
            self.alertTimer = nil
            self.alertController!.dismiss(animated: true, completion: {
                self.alertController = nil
            })
        } else {
        }
    }

 
}

extension HomeViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? NBRequest {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
                let button = UIButton(type: .detailDisclosure)
                button.setImage(UIImage(named: "Forward-32"), for: UIControlState.normal)
                view.rightCalloutAccessoryView = button
                view.tintColor = UIColor.lightGray
            }
            
            switch annotation.requestType {
            case .buying:
                view.pinTintColor = UIColor.nbBlue
            case .selling:
                view.pinTintColor = UIColor.purple
            case .loaning:
                view.pinTintColor = UIColor.purple
            case .renting:
                view.pinTintColor = UIColor.nbBlue
            case .none:
                view.pinTintColor = UIColor.nbBlue
            }
            let image = UIImage(named: "User-64")
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
            view.leftCalloutAccessoryView = imageView
            
            if let pictureURL = annotation.user?.imageUrl {
                NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    imageView.contentMode = UIViewContentMode.scaleAspectFill
                    imageView.layer.cornerRadius = imageView.frame.size.width / 2
                    imageView.clipsToBounds = true
                    view.leftCalloutAccessoryView = imageView
                })
            }
            
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailRequestVC = storyboard.instantiateViewController(
            withIdentifier: "RequestDetailTableViewController") as? RequestDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return
        }
        let request = view.annotation as! NBRequest?
        detailRequestVC.request = request
        detailRequestVC.delegate = self
        detailRequestVC.mode = (request?.isMyRequest())! ? .buyer : .seller
        self.navigationController?.pushViewController(detailRequestVC, animated: true)
    }
    
    func getRadius() -> CLLocationDistance {
        let meters = Converter.milesToMeters(searchFilter.searchRadius)
        return CLLocationDistance(meters)
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        if (searchFilter.searchBy == "home address") {
            var lat = 0.0
            var lng = 0.0
            UserManager.sharedInstance.getUser { fetchedUser in
                lat = Double(fetchedUser.homeLatitude!)
                lng = Double(fetchedUser.homeLongitude!)
            }
            print("home lat: \(lat) and home lng: \(lng)")
            return CLLocationCoordinate2D.init(latitude: lat, longitude: lng);
        } else {
            let currentLocation = LocationManager.sharedInstance.location
            return CLLocationCoordinate2D.init(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!);
            //return self.mapView.centerCoordinate
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("map moving")
        searchBar.endEditing(true)
        //self.view.bringSubview(toFront: reloadView)
        self.view.bringSubview(toFront: requestButton)
    }
}

extension HomeViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    /*
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "pin_grey_150")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "no requests found")
    }
    */
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! HomeTableViewCell

        let request = requests[(indexPath as NSIndexPath).section]
        let name = request.isMyRequest() ? "You" : (request.user?.shortName ?? "NAME")
        let rent = request.requestType.rawValue.replacingOccurrences(of: "ing", with: "")
        let item = request.itemName ?? "ITEM"
        
        let attrText = NSMutableAttributedString(string: "")
        let boldFont = UIFont.boldSystemFont(ofSize: 16)
        
        let boldFullname = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldFullname)
        
        switch (request.requestType) {
        case RequestType.loaning:
            attrText.append(NSMutableAttributedString(string: " has a \(item) available to rent"))
            break
        case RequestType.selling:
            attrText.append(NSMutableAttributedString(string: " is selling a \(item)"))
            break
        default:
            attrText.append(NSMutableAttributedString(string: " wants to \(rent) a \(item)"))
            break
        }        
        cell.attributedMessage = attrText
        
        /*
        let request = requests[(indexPath as NSIndexPath).section]
        let name = request.user?.shortName ?? "NAME"
        let rent = (request.rental)! ? "borrow" : "buy"
        
        let attrText = NSMutableAttributedString(string: "")
        let boldFont = UIFont.boldSystemFont(ofSize: 15)
        
        let boldFullname = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldFullname)
        
        attrText.append(NSMutableAttributedString(string: " wants to \(rent) "))
        
        let boldItemName = NSMutableAttributedString(string: request.itemName!, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldItemName)
        
        attrText.append(NSMutableAttributedString(string: "."))

        cell.messageLabel.attributedText = attrText
        */
        
        let myLocation = LocationManager.sharedInstance.location
        let distanceString = request.getDistanceAsString(fromLocation: myLocation!)
        cell.distance = distanceString
        
        cell.time = request.getElapsedTimeAsString()

        cell.userImage = UIImage(named: "User-64")
        
        if let pictureURL = request.user?.imageUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                if let cellToUpdate = self.tableView?.cellForRow(at: indexPath) as! HomeTableViewCell? {
                    cellToUpdate.userImage = image
                }
            })
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = requests[(indexPath as NSIndexPath).section]
        
        let detailRequestVC = UIStoryboard.getDetailRequestVC() as! RequestDetailTableViewController
        detailRequestVC.delegate = self
        detailRequestVC.request = request
        detailRequestVC.mode = request.isMyRequest() ? .buyer : .seller
        self.navigationController?.pushViewController(detailRequestVC, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let request = requests[(indexPath as NSIndexPath).section]
//        
//        if request.isMyRequest() {
//            let close = UITableViewRowAction(style: .normal, title: "Close") { action, index in
//                self.requestClosed(request)
//                self.tableView.isEditing = false
//            }
//            close.backgroundColor = UIColor.nbRed
//            
//            return [close]
//        }
//        else {
//            let respond = UITableViewRowAction(style: .normal, title: "Respond") { action, index in
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                guard let navVC = storyboard.instantiateViewController(
//                    withIdentifier: "NewResponseNavigationController") as? UINavigationController else {
//                        assert(false, "Misnamed view controller")
//                        return
//                }
//                UserManager.sharedInstance.getUser { fetchedUser in
//                    if (!fetchedUser.hasAllRequiredFields()) {
//                        self.showAlertMsg(message: "You must finish filling out your profile before you can make offers")
//                        
//                    } else if ((request.type == RequestType.renting.rawValue || request.type == RequestType.buying.rawValue) && !fetchedUser.canRespond!) {
//                        self.showAlertMsg(message: "You must add bank account information before you can make offers")
//                    } else if (request.type == RequestType.loaning.rawValue || request.type == RequestType.selling.rawValue) && !fetchedUser.canRequest! {
//                        self.showAlertMsg(message: "You must add credit card information before you can reply")
//                    } else {
//                        let responseVC = (navVC.childViewControllers[0] as! NewResponseTableViewController)
//                        responseVC.delegate = self
//                        responseVC.request = request
//                        self.present(navVC, animated: true, completion: nil)
//                        
//                        self.tableView.isEditing = false
//                    }
//                }
//            }
//            respond.backgroundColor = UIColor.nbBlue
//            
//            let flagRequest = UITableViewRowAction(style: .normal, title: "Flag") { action, index in
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                guard let navVC = storyboard.instantiateViewController(
//                    withIdentifier: "FlagNavigationController") as? UINavigationController else {
//                        assert(false, "Misnamed view controller")
//                        return
//                }
//                let flagVC = (navVC.childViewControllers[0] as! FlagTableViewController)
////                flagVC.delegate = self
////                flagVC.request = request
//                let requestId = request.id
//                flagVC.mode = .request(requestId!)
//                self.present(navVC, animated: true, completion: nil)
//                
//                self.tableView.isEditing = false
//            }
//            flagRequest.backgroundColor = UIColor.nbRed
//            
//            let blockUser = UITableViewRowAction(style: .normal, title: "Block") { action, index in
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                guard let navVC = storyboard.instantiateViewController(
//                    withIdentifier: "FlagNavigationController") as? UINavigationController else {
//                        assert(false, "Misnamed view controller")
//                        return
//                }
//                let flagVC = (navVC.childViewControllers[0] as! FlagTableViewController)
//                let userId = request.user?.id
//                flagVC.mode = .user(userId!)
//                self.present(navVC, animated: true, completion: nil)
//                
//                self.tableView.isEditing = false
//            }
//            blockUser.backgroundColor = UIColor.orange
//            
//            return [blockUser, flagRequest, respond]
//        }
//    }
    
    func refresh(_ sender: AnyObject) {
//        nextPageURLString = nil // so it doesn't try to append the results
        NearbyAPIManager.sharedInstance.clearCache()
        let radius = getRadius()
        let center = self.getCenterCoordinate()
        self.loadRequests(center.latitude, longitude: center.longitude, radius: radius)
    }
    
}

extension HomeViewController: FilterTableViewDelegate {
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let navVC = storyboard.instantiateViewController(withIdentifier: "FilterNavigationController") as? UINavigationController else {
            assert(false, "Misnamed view controller")
            return
        }
        let filterVC = (navVC.childViewControllers[0] as! FilterTableViewController)
        filterVC.delegate = self
        filterVC.filter = searchFilter
        self.present(navVC, animated: true, completion: nil)
    }
    
    func searched() {
        let radius = self.getRadius()
        let center = self.getCenterCoordinate()
        
        reloadRequests(center.latitude, longitude: center.longitude, radius: radius)
    }
    
    func cancelled() {
    }
    
}

extension HomeViewController: NewRequestTableViewDelegate, NewResponseTableViewDelegate, RequestDetailTableViewDelegate, EditRequestTableViewDelegate {
    
    @IBAction func requestButtonPressed(_ sender: UIButton) {
        UserManager.sharedInstance.getUser { fetchedUser in
            if (!fetchedUser.hasAllRequiredFields()) {
                self.showAlertMsg(message: "You must finish filling out your profile before you can make requests")

            } else if (!fetchedUser.canRequest!) {
                self.showAlertMsg(message: "You must add payment info before you can make requests")
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let navVC = storyboard.instantiateViewController(
                    withIdentifier: "NewRequestNavigationController") as? UINavigationController else {
                        assert(false, "Misnamed view controller")
                        return
                }
                let newRequestVC = (navVC.childViewControllers[0] as! NewRequestTableViewController)
                newRequestVC.delegate = self
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    //request
    func saved(_ request: NBRequest?) {
        print("HomeViewController->saved")
        requestSaved(request)
    }
    
    func edited(_ request: NBRequest?) {
        print("HomeViewController->edited")
        requestEdited(request)
    }
    
    func closed(_ request: NBRequest?) {
        print("HomeViewController->closed")
        requestClosed(request)
    }
    
    func requestSaved(_ request: NBRequest?) {
        print("HomeViewController->requestSaved")
        let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Saving")
        
        if let request = request {
            NBRequest.addRequest(request) { error in
                print("Request added")
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.loadRequests()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.showHistoryView()
            }
        }
    }
    
    func requestClosed(_ request: NBRequest?) {
        print("HomeViewController->requestClosed")
        if let request = request {
            request.expireDate = 0
//            request.requestStatus = RequestStatus.closed
            NBRequest.editRequest(request) { error in
                print("Request closed")
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.loadRequests()
            }
        }
    }
    
    func requestEdited(_ request: NBRequest?) {
        print("HomeViewController->requestEdited")
        if let request = request {
            NBRequest.editRequest(request) { error in
                print("Request edited")
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.loadRequests()
            }
        }
    }
    
    //response
    func saved(_ response: NBResponse?) {
        print("HomeViewController->saved")
        responseOffered(response)
    }
    
    func offered(_ response: NBResponse?) {
        print("HomeViewController->offered")
        responseOffered(response)
    }
    
    func responseOffered(_ response: NBResponse?) {
        print("HomeViewController->responseOffered")
        let loadingNotification = Utils.createProgressHUD(view: self.view, text: "Saving")
        
        if let response = response {
            NBResponse.addResponse(response) { error in
                print("Response added")
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.loadRequests()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.showHistoryView()
            }
        }
    }
    
}
