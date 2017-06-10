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
import AWSCore
import AWSCognito
import NYTPhotoViewer


protocol NewRequestTableViewDelegate: class {
    
    func saved(_ request: NBRequest?)
    
    func cancelled()
    
}

class NewRequestTableViewController: UITableViewController {

    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var requestLocationButton: UIButton!
    @IBOutlet weak var rentalButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos: [NBPhoto] = []
    
    let requestLocationDropDown = DropDown()
    let rentalDropDown = DropDown()
    
    let picker = UIImagePickerController()
    
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
            "buy",
            "sell",
            "loan"
        ]
        
        self.rentalButton.setTitle("rent", for: .normal)
        // Action triggered on selection
        rentalDropDown.selectionAction = { [unowned self] (index, item) in
            self.rentalButton.setTitle(item, for: .normal)
            switch item {
            case "rent":
                self.rental = RequestType.renting
            case "buy":
                self.rental = RequestType.buying
            case "sell":
                self.rental = RequestType.selling
            case "loan":
                self.rental = RequestType.loaning
            default:
                self.rental = RequestType.none
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
    
    var rental: RequestType = RequestType.renting

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDropDowns()

        picker.delegate = self
        
        saveButton.layer.cornerRadius = 4
        saveButton.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        saveButton.layer.borderWidth = 1.0
        saveButton.clipsToBounds = true
        
        collectionView.delegate = self
        
        self.hideKeyboardWhenTappedAround()

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
        rental = request.requestType
    }
    
    func saveFields(request: NBRequest) {
        request.itemName = itemName
        request.desc = desc
        request.requestType = rental
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
        
        let photoStringArray = AWSManager.sharedInstance.uploadPhotos(photos: photos)
        req.photos = photoStringArray
        
        saveFields(request: req)
        
//        req.type = "item"
       
        self.delegate?.saved(req)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
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

extension NewRequestTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == photos.count { //camera
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath)
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.photoButtonPressed))
            cell.addGestureRecognizer(tap)
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
            cell.addGestureRecognizer(tap)
            
            cell.photoImageView.image = photos[indexPath.row].image
            return cell
        }
    }
    
    func photoButtonPressed() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { action in
            self.cameraButtonPressed()
        }
        alertController.addAction(cameraAction)
        
        let chooserAction = UIAlertAction(title: "Choose from album", style: .default) { action in
            self.chooserButtonPressed()
        }
        alertController.addAction(chooserAction)
        
        self.present(alertController, animated: true) {
        }
        
    }
    
    func chooserButtonPressed() {
        print("photo button")
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func cameraButtonPressed() {
        print("camera button")
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        present(picker,animated: true,completion: nil)
    }
    
    func removeImage(sender: UITapGestureRecognizer) {
    }
}


extension NewRequestTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let photo = NBPhoto(image: chosenImage)
        photos.append(photo)
        self.collectionView.reloadData()
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
