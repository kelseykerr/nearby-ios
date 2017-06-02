//
//  NewRequestTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import MapKit
import DropDown

protocol NewRequestTableViewDelegate: class {
    
    func saved(_ request: NBRequest?)
    
    func cancelled()
    
}

class NewRequestTableViewController: UITableViewController {

    @IBOutlet var itemNameTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var rentImageView: UIImageView!
    @IBOutlet var buyImageView: UIImageView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var requestLocationButton: UIButton!
    @IBOutlet var rentalButton: UIButton!
    
    let requestLocationDropDown = DropDown()
    let rentalDropDown = DropDown()
    
    var currentMapView = "current location"
    
    weak var delegate: NewRequestTableViewDelegate?
    var request: NBRequest?
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.requestLocationDropDown,
            self.rentalDropDown
        ]
    }()
    
    @IBAction func chooseRental(_ sender: AnyObject) {
        rentalDropDown.show()
    }
    
    @IBAction func chooseLocation(_ sender: AnyObject) {
        requestLocationDropDown.show()
    }
    
    func setupDefaultDropDown() {
        DropDown.setupDefaultAppearance()
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.customCellConfiguration = nil
        }
    }
    
    func setupDropDowns() {
        setupRequestLocationDropDown()
        setupRentalDropDown()
    }
    
    func setupRequestLocationDropDown() {
        requestLocationDropDown.anchorView = requestLocationButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        requestLocationDropDown.bottomOffset = CGPoint(x: 0, y: requestLocationButton.bounds.height)
        requestLocationDropDown.dataSource = [
            "current location",
            "home address"
        ]
        
        self.requestLocationButton.setTitle("current location", for: .normal)
        // Action triggered on selection
        requestLocationDropDown.selectionAction = { [unowned self] (index, item) in
            self.requestLocationButton.setTitle(item, for: .normal)
            if (item == "current location" && self.currentMapView != item) {
                self.currentMapView = item
                self.setupMapCurrentLocation()
            } else if (item == "home address" && self.currentMapView != item) {
                self.currentMapView = item
                self.setupMapHomeAddress()
            }
            
        }
    }

    func setupRentalDropDown() {
        rentalDropDown.anchorView = rentalButton
        
        rentalDropDown.bottomOffset = CGPoint(x: 0, y: rentalButton.bounds.height)
        rentalDropDown.dataSource = [
            "rent",
            "buy"
        ]
        
        self.rentalButton.setTitle("rent", for: .normal)
        // Action triggered on selection
        rentalDropDown.selectionAction = { [unowned self] (index, item) in
            self.rentalButton.setTitle(item, for: .normal)
            if item == "rent" {
                self.rental = true
            } else if item == "buy" {
                self.rental = false
            }
            
        }
    }
    
    var itemName: String? {
        get {
            return itemNameTextField.text
        }
        set {
            itemNameTextField.text = newValue
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
    
    var rental = true
//    var rental: Bool {
//        get {
//            return !self.rentImageView.isHidden
//        }
//        set {
//            self.rentImageView.isHidden = !newValue
//            self.buyImageView.isHidden = newValue
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDropDowns()

        saveButton.layer.cornerRadius = saveButton.frame.size.height / 16
        saveButton.clipsToBounds = true
        
        self.hideKeyboardWhenTappedAround()
//        rental = true

        if request != nil {
            loadFields(request: request!)
        }
        self.mapView.delegate = self
        self.view.bringSubview(toFront: mapView)
        setupMapCurrentLocation()
    }
    
    func loadFields(request: NBRequest) {
        itemName = request.itemName
        desc = request.desc
        rental = request.rental!
    }
    
    func saveFields(request: NBRequest) {
        request.itemName = itemName
        request.desc = desc
        request.rental = rental
    }
    
    func setupMapCurrentLocation() {
        mapView.removeAnnotations(mapView.annotations)
        let currentLocation = LocationManager.sharedInstance.location
        let myLocation2D = CLLocationCoordinate2D.init(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!)
        print(myLocation2D)
        let meters = Converter.milesToMeters(0.25)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation2D, meters * 2.0, meters * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.isZoomEnabled = false;
        mapView.isScrollEnabled = false;
        let identifier = "pin"
        var view: MKPinAnnotationView
        let annotation = MKPointAnnotation.init()
        annotation.coordinate = myLocation2D
        annotation.title = "request location"
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
            view.tintColor = UIColor.nbBlue
        }
        self.mapView.addAnnotation(annotation)
    }
    
    func setupMapHomeAddress() {
        mapView.removeAnnotations(mapView.annotations)
        let lat = Double((UserManager.sharedInstance.user?.homeLatitude)!)
        let lng = Double((UserManager.sharedInstance.user?.homeLongitude)!)
        let myLocation2D = CLLocationCoordinate2D.init(latitude: lat, longitude: lng)
        print(myLocation2D)
        let meters = Converter.milesToMeters(0.25)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation2D, meters * 2.0, meters * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.isZoomEnabled = false;
        mapView.isScrollEnabled = false;
        let identifier = "pin"
        var view: MKPinAnnotationView
        let annotation = MKPointAnnotation.init()
        annotation.coordinate = myLocation2D
        annotation.title = "request location"
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
            view.tintColor = UIColor.nbBlue
        }
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        var req = NBRequest()
        
        if request == nil {
            let annotation = mapView.annotations[0]
            req.latitude = annotation.coordinate.latitude
            req.longitude = annotation.coordinate.longitude
        
            let postDate64: Int64 = Int64(Date().timeIntervalSince1970) * 1000
            req.postDate = postDate64
            
            let oneWeek = 60 * 60 * 24 * 7.0
            let tenYears = 60 * 60 * 24 * 7.0 * 52 * 10
            let expireDate64: Int64 = Int64(Date().addingTimeInterval(tenYears).timeIntervalSince1970) * 1000
            req.expireDate = expireDate64
        }
        else {
            req = request?.copy() as! NBRequest
        }
        
        saveFields(request: req)
        
        req.type = "item"
       
        self.delegate?.saved(req)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rentButtonPressed(_ sender: UIButton) {
        rental = true
    }

    @IBAction func buyButtonPressed(_ sender: UIButton) {
        rental = false
    }
    
    @IBAction func handleTouchWithGestureRecognizer(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        annotation.title = "request location"
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
}

extension NewRequestTableViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("map moving")
        //self.view.bringSubview(toFront: requestButton)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var v : MKAnnotationView! = nil
        let ident = "request location"
        v = mapView.dequeueReusableAnnotationView(withIdentifier:ident)
        if v == nil {
            v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ident)
        }
        v.annotation = annotation
        v.isDraggable = true
        return v
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
        }
    }
}
