//
//  HomeViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/21/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController, LoginViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var reloadView: UIToolbar!
    var searchBar: UISearchBar = UISearchBar()
    
    var requests = [NBRequest]()
    var nextPageURLString: String?
    var isLoading = false
    var dateFormatter = DateFormatter()

    var searchFilter = SearchFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // temp, logs out so we can test login
        //        let manager = FBSDKLoginManager()
        //        manager.logOut()
        
        if LocationManager.sharedInstance.locationAvailable() {
            print(LocationManager.sharedInstance.location)
        }
        
        let image = UIImage(named: "nearby_logo")
        let imageView = UIImageView(image: image)
        
        self.navigationItem.titleView = imageView
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.barTintColor = UIColor.red
        navigationController?.navigationBar.shadowImage = UIImage()
        
//        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.frame = CGRect(x: 0, y: 0, width: (navigationController?.view.bounds.size.width)!, height: 44)
        searchBar.barStyle = .default
        searchBar.isTranslucent = false
        searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        searchBar.backgroundImage = UIImage()
        view.addSubview(searchBar)
        
        self.mapView.delegate = self
        self.view.bringSubview(toFront: mapView)
        self.view.bringSubview(toFront: searchBar)
//        self.view.bringSubview(toFront: reloadView)
        loadInitialData()
    }
    
    
    func loadInitialData() {
        if (!AccountManager.sharedInstance.hasOAuthToken()) {
            showOAuthLoginView()
            return
        }
        
        let currentLocation = LocationManager.sharedInstance.location
        loadRequests((currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!, radius: 1000)
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
            
            let currentLocation = LocationManager.sharedInstance.location
            self.loadRequests((currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!, radius: 1000)
        }
    }
    
    func reloadRequests(_ latitude: Double, longitude: Double, radius: Double) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
//        mapView.setRegion(coordinateRegion, animated: true)
        
        let includeMine = searchFilter.includeMyRequest
        let expired = searchFilter.includeExpiredRequest
        let sort = searchFilter.sortRequestByDate ? "distance": "newest"
        
        NBRequest.fetchRequests2(latitude, longitude: longitude, radius: Converter.metersToMiles(radius), expired: expired, includeMine: includeMine, searchTerm: "blah", sort: sort) { result in
//        NBRequest.fetchRequests(latitude, longitude: longitude, radius: Converter.metersToMiles(radius)) { result in
//            if self.refreshControl != nil && self.refreshControl!.refreshing {
//                self.refreshControl?.endRefreshing()
//            }
            
            print(result)
            
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let fetchedRequests = result.value else {
                print("no requests fetched")
                return
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
        
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
            
        let includeMine = searchFilter.includeMyRequest
        let expired = searchFilter.includeExpiredRequest
        let sort = searchFilter.sortRequestByDate ? "distance": "newest"
        
        NBRequest.fetchRequests2(latitude, longitude: longitude, radius: Converter.metersToMiles(radius), expired: expired, includeMine: includeMine, searchTerm: "blah", sort: sort) { result in
//        NBRequest.fetchRequests(latitude, longitude: longitude, radius: Converter.metersToMiles(radius)) { result in
//            if self.refreshControl != nil && self.refreshControl!.refreshing {
//                self.refreshControl?.endRefreshing()
//            }
            
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let fetchedRequests = result.value else {
                print("no requests fetched")
                return
            }
            
            for req in fetchedRequests {
                print(req.toString())
            }
            
            self.mapView.addAnnotations(fetchedRequests)
            self.requests = fetchedRequests
            
            self.tableView.reloadData()
        }
    }
    
//    func refresh(sender: AnyObject) {
//        //        nextPageURLString = nil // so it doesn't try to append the results
//        NearbyAPIManager.sharedInstance.clearCache()
//        loadRequests()
//    }
    
    @IBAction func listMapButtonPressed(_ sender: UIBarButtonItem) {
        if sender.title == "List" {
            sender.title = "Map"
            self.view.bringSubview(toFront: tableView)
        }
        else {
            sender.title = "List"
            self.view.bringSubview(toFront: mapView)
            self.view.bringSubview(toFront: searchBar)
            self.view.bringSubview(toFront: reloadView)
        }
    }
    
    @IBAction func redoSearchButtonPressed(_ sender: UIBarButtonItem) {
        let radius = self.getRadius()
        let center = self.getCenterCoordinate()
        
//        print(radius)
//        print(center)

        reloadRequests(center.latitude, longitude: center.longitude, radius: radius)
        self.view.bringSubview(toFront: mapView)
        self.view.bringSubview(toFront: searchBar)
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
            
            if let pictureURL = annotation.user?.pictureUrl {
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
        guard let requestDetailVC = storyboard.instantiateViewController(
            withIdentifier: "DetailViewController") as? RequestDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return
        }
        requestDetailVC.request = view.annotation as! NBRequest?
        self.navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    func getRadius() -> CLLocationDistance {
        let center = self.getCenterCoordinate()
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        let top = self.mapView.convert(CGPoint(x: self.mapView.frame.size.width / 2.0, y: 0), toCoordinateFrom: mapView)
        let topLocation = CLLocation(latitude: top.latitude, longitude: top.longitude)
        
        let radius = centerLocation.distance(from: topLocation)
        return radius;
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        return self.mapView.centerCoordinate
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("map moving")
        self.view.bringSubview(toFront: reloadView)
    }
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
        
        let firstName = (request.user?.firstName)!
        let lastName = (request.user?.lastName)!

        let text = " wants to \(((request.rental)! ? "borrow" : "buy")) "
        let attrText = NSMutableAttributedString(string: "")
        let boldFont = UIFont.boldSystemFont(ofSize: 15)
        let boldFullname = NSMutableAttributedString(string: "\(firstName) \(lastName)", attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldFullname)
        attrText.append(NSMutableAttributedString(string: text))
        
        let boldItemName = NSMutableAttributedString(string: request.itemName!, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldItemName)
        attrText.append(NSMutableAttributedString(string: "."))

        //setting cell's views
        cell.messageLabel.attributedText = attrText
        cell.messageLabel.sizeToFit()
        
        cell.time = request.getElapsedTimeAsString()
        
        let myLocation = LocationManager.sharedInstance.location
        let distanceString = request.getDistanceAsString(fromLocation: myLocation!)
        cell.distance = distanceString
        
        cell.userImageView.image = UIImage(named: "User-64")
        cell.setNeedsLayout()
        
//        cell.sizeToFit()
        
        if let pictureURL = request.user?.pictureUrl {
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                if let cellToUpdate = self.tableView?.cellForRow(at: indexPath) as! HomeTableViewCell? {
                    cellToUpdate.userImageView?.image = image // will work fine even if image is nil // need to reload the view, which won't happen otherwise
                    // since this is in an async call
                    cellToUpdate.setNeedsLayout()
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
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let requestDetailVC = storyboard.instantiateViewController(
            withIdentifier: "RequestDetailTableViewController") as? RequestDetailTableViewController else {
                assert(false, "Misnamed view controller")
                return
        }
        requestDetailVC.request = requests[(indexPath as NSIndexPath).section]
        self.navigationController?.pushViewController(requestDetailVC, animated: true)
    }
    
    func refresh(_ sender: AnyObject) {
//        nextPageURLString = nil // so it doesn't try to append the results
        NearbyAPIManager.sharedInstance.clearCache()
        self.loadRequests(37.5789, longitude: -122.3451, radius: 1000)
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
