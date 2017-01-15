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
        
        self.mapView.delegate = self
        self.view.bringSubview(toFront: mapView)
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
        
        NBRequest.fetchRequests2(latitude, longitude: longitude, radius: Converter.metersToMiles(radius), expired: false, includeMine: true, searchTerm: "blah", sort: "newest") { result in
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

    func loadRequests(_ latitude: Double, longitude: Double, radius: Double) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
            
        NBRequest.fetchRequests(latitude, longitude: longitude, radius: Converter.metersToMiles(radius)) { result in
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
//            self.view.bringSubview(toFront: reloadView)
        }
    }
    
    @IBAction func redoSearchButtonPressed(_ sender: UIBarButtonItem) {
        let radius = self.getRadius()
        let center = self.getCenterCoordinate()
        
//        print(radius)
//        print(center)

        reloadRequests(center.latitude, longitude: center.longitude, radius: radius)
        self.view.bringSubview(toFront: mapView)
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
        if segue.identifier == "PushFilterTableViewController" {
            print("filter called")
            let filterVC = segue.destination.childViewControllers[0] as! FilterTableViewController
            filterVC.filter = searchFilter
            filterVC.delegate = self
        }
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
//                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
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
        
//        cell.subject = request.itemName!
//        cell.desc = request.desc!
        let firstName = (request.user?.firstName)!
        let lastName = (request.user?.lastName)!
//        cell.desc = "\(firstName) \(lastName) ∙ 1 Miles ∙ 10 Days Ago"
        
//        cell.textLabel?.text = request.itemName
//        cell.detailTextLabel?.text = request.desc
///        cell.item = request.itemName!
///        cell.name = "\(firstName) \(lastName)"
///        cell.time = "3 Days"
///        cell.distance = "10 Miles"
        
//        cell.textLabel?.text = "\(firstName) \(lastName) wants to borrow \(request.itemName!)."

        let text = " wants to borrow "
        let attrText = NSMutableAttributedString(string: "")
        let boldFont = UIFont.boldSystemFont(ofSize: 17)
        let boldFullname = NSMutableAttributedString(string: "\(firstName) \(lastName)", attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldFullname)
        attrText.append(NSMutableAttributedString(string: text))
        
        let boldItemName = NSMutableAttributedString(string: request.itemName!, attributes: [NSFontAttributeName: boldFont])
        attrText.append(boldItemName)
        attrText.append(NSMutableAttributedString(string: "."))
        
        cell.textLabel?.attributedText = attrText
        
//        let userImage = UIImage(named: "IMG_1426")
//        cell.imageView?.image = userImage
//        print("YO")
//        print(userImage?.size.width)
//        print("YO")
//        cell.imageView?.layer.cornerRadius = (userImage?.size.width)! / 2
//        cell.imageView?.clipsToBounds = true
        
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
        print("Yoo1")
        print(indexPath)
        print(requests[(indexPath as NSIndexPath).section].toString())
        print("Yoo2")
    }
    
    func refresh(_ sender: AnyObject) {
//        nextPageURLString = nil // so it doesn't try to append the results
        NearbyAPIManager.sharedInstance.clearCache()
        self.loadRequests(37.5789, longitude: -122.3451, radius: 1000)
    }
}

extension HomeViewController: FilterTableViewDelegate {
    
    func cancelled() {
        print("yo cancelled")
    }
    
    func searched() {
        print("yo searched")
        
        let radius = self.getRadius()
        let center = self.getCenterCoordinate()
        
        //        print(radius)
        //        print(center)
        
        reloadRequests(center.latitude, longitude: center.longitude, radius: radius)
    }
}
