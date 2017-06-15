//
//  NewResponseTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/7/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import NYTPhotoViewer


protocol NewResponseTableViewDelegate: class {
    
    func saved(_ response: NBResponse?)
    
    func cancelled()
    
}

class NewResponseTableViewController: UITableViewController {

    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var pickupLocationTextField: UITextField!
    @IBOutlet var pickupTimeDatePicker: UIDatePicker!
    @IBOutlet var pickupTimeDateTextField: UITextField!
    @IBOutlet var returnLocationTextField: UITextField!
    @IBOutlet var returnTimeDatePicker: UIDatePicker!
    @IBOutlet var returnTimeDateTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var messagesEnabledSwitch: UISwitch!
    @IBOutlet weak var collectionView: ImageCollectionView!

    /*@IBOutlet var perHourImageView: UIImageView!
    @IBOutlet var perDayImageView: UIImageView!
    @IBOutlet var flatImageView: UIImageView!*/
    
    @IBOutlet var saveButton: UIButton!
    
    var photos: [NBPhoto] = []
    
    weak var delegate: NewResponseTableViewDelegate?
    var request: NBRequest?
    var response: NBResponse?
    
    let pickupDatePicker = UIDatePicker()
    let returnDatePicker = UIDatePicker()
    
    let picker = UIImagePickerController()
    
    let dateFormatter = DateFormatter()
    
    var price: Float? {
        get {
            let priceString = priceTextField.text
            return Float(priceString!)
        }
        set {
            priceTextField.text = "\(newValue)"
        }
    }
    
    var responseDescription: String? {
        get {
            return descriptionTextView.text
        }
        set {
            descriptionTextView.text = newValue
        }
    }
    
    var pickupLocation: String? {
        get {
            return pickupLocationTextField.text
        }
        set {
            pickupLocationTextField.text = newValue
        }
    }
    
    var returnLocation: String? {
        get {
            return returnLocationTextField.text
        }
        set {
            returnLocationTextField.text = newValue
        }
    }
    
    var priceType: PriceType {
        get {
            /*if !self.perHourImageView.isHidden {
                return .per_hour
            }
            else if !self.perDayImageView.isHidden {
                return .per_day
            }
            else {
                return .flat
            }*/
            return .flat
        }
        set {
            /*self.perHourImageView.isHidden = (newValue != .per_hour)
            self.perDayImageView.isHidden = (newValue != .per_day)
            self.flatImageView.isHidden = (newValue != .flat)*/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        self.hideKeyboardWhenTappedAround()
//        priceType = .per_hour
        priceType = .flat
        
        saveButton.layer.cornerRadius = 4
        saveButton.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        saveButton.layer.borderWidth = 1.0
        saveButton.clipsToBounds = true
        
        createDatePickers()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let response = response {
            loadFields(response: response)
        }
    }
    
    func createDatePickers() {
        let pickupToolbar = UIToolbar()
        pickupToolbar.sizeToFit()
        
        let spaceBarItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let pickupDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(pickupDoneButtonPressed))
        pickupToolbar.setItems([spaceBarItem, pickupDoneButton], animated: false)
        
        pickupTimeDateTextField.inputAccessoryView = pickupToolbar
        pickupTimeDateTextField.inputView = pickupDatePicker
        
        let returnToolbar = UIToolbar()
        returnToolbar.sizeToFit()
        
        let returnDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(returnDoneButtonPressed))
        returnToolbar.setItems([spaceBarItem, returnDoneButton], animated: false)
        
        returnTimeDateTextField.inputAccessoryView = returnToolbar
        returnTimeDateTextField.inputView = returnDatePicker
    }
    
    func pickupDoneButtonPressed() {
        pickupTimeDateTextField.text = dateFormatter.string(from: pickupDatePicker.date)
        self.view.endEditing(true)
    }
    
    func returnDoneButtonPressed() {
        returnTimeDateTextField.text = dateFormatter.string(from: returnDatePicker.date)
        self.view.endEditing(true)
        
    }
    
    func loadFields(response: NBResponse) {
        price = response.offerPrice
        pickupLocation = response.exchangeLocation
        returnLocation = response.returnLocation
        responseDescription = response.description
    }
    
    func saveFields(response: NBResponse) {
        response.offerPrice = price
        response.exchangeLocation = pickupLocation
        response.returnLocation = returnLocation
        response.description = responseDescription
    }
    
    //magic numbers are bad
    //really should be checking rental againt some enum? and maybe check if nil in the model itself
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 4 && (request?.requestType == RequestType.buying || request?.requestType == RequestType.selling) {
            return nil
        }
        else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 && (request?.requestType == RequestType.buying || request?.requestType == RequestType.selling) {
            return 0.1
        }
        else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 4 && (request?.requestType == RequestType.buying || request?.requestType == RequestType.selling) {
            return 0.1
        }
        else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 && (request?.requestType == RequestType.buying || request?.requestType == RequestType.selling) {
            return 0
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("response cancelled")
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        print("response saved")

        if response == nil {
            let resp = NBResponse(test: true)
            response = resp
        }
        
        saveFields(response: response!)
        
        response?.offerPrice = price
        response?.description = responseDescription
        response?.requestId = request?.id
        response?.responderId = UserManager.sharedInstance.user?.userId
        response?.exchangeLocation = pickupLocation
        //do not set a default pickup time - leave it empty if the user didn't enter anything
        if (!(pickupTimeDateTextField.text ?? "").isEmpty) {
            response?.exchangeTime = Int64(pickupDatePicker.date.timeIntervalSince1970) * 1000
        }
        response?.returnLocation = returnLocation
        //do not set a default return time - leave it empty if the user didn't enter anything
        if (!(returnTimeDateTextField.text ?? "").isEmpty) {
            response?.returnTime = Int64(returnDatePicker.date.timeIntervalSince1970) * 1000
        }
        response?.messagesEnabled = messagesEnabledSwitch.isOn
//        response?.priceType = priceType
        response?.priceType = .flat
        
        let photoStringArray = AWSManager.sharedInstance.photoActions(photos: photos)
        response?.photos = photoStringArray
        
        delegate?.saved(response)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func perHourButtonPressed(_ sender: UIButton) {
//        priceType = .per_hour
    }
    
    @IBAction func perDayButtonPressed(_ sender: UIButton) {
//        priceType = .per_day
    }
    
    @IBAction func flatButtonPressed(_ sender: UIButton) {
        priceType = .flat
    }
    
}

extension NewResponseTableViewController: ImageCollectionViewDelegate, UICollectionViewDataSource {
    
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
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            
            cell.photoImageView.image = photos[indexPath.row].image
            
            return cell
        }
    }
    
    func photoButtonPressed() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let cameraAction = UIAlertAction(title: "Take a photo with camera", style: .default) { action in
            self.takePhoto()
        }
        alertController.addAction(cameraAction)
        
        let chooserAction = UIAlertAction(title: "Choose from album", style: .default) { action in
            self.choosePhoto()
        }
        alertController.addAction(chooserAction)
        
        self.present(alertController, animated: true) {
        }
        
    }
    
    func choosePhoto() {
        print("photo button")
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func takePhoto() {
        print("camera button")
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        present(picker,animated: true,completion: nil)
    }
    
    func removeImage(index: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        alertController.addAction(cancelAction)
        
        let removeAction = UIAlertAction(title: "Remove this photo", style: .destructive) { action in
            print("removing image")
            self.photos.remove(at: index)
            self.collectionView.reloadData()
        }
        alertController.addAction(removeAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == photos.count { //camera
            if photos.count < 3 {
                photoButtonPressed()
            }
            else {
                let alertController = UIAlertController(title: nil, message: "You cannot add more than 3 photos.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else {
            let photo = photos[indexPath.row]
            let photosVC = NYTPhotosViewController(photos: photos, initialPhoto: photo)
            self.present(photosVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemToRemoveAt indexPath: IndexPath) {
        if indexPath.row != photos.count {
            removeImage(index: indexPath.row)
        }
    }
}

extension NewResponseTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let photo = NBPhoto(image: chosenImage)
        photos.append(photo)
        photo.awsActionType = .upload
        self.collectionView.reloadData()
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
