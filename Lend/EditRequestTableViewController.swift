//
//  EditRequestDetailTableViewController.swift
//  Nearby
//
//  Created by Kerr, Kelsey on 4/13/17.
//  Copyright © 2017 Iuxta, Inc. All rights reserved.
//

import UIKit
import NYTPhotoViewer


protocol EditRequestTableViewDelegate: class {
    
    func edited(_ request: NBRequest?)
    
    func closed(_ request: NBRequest?)
    
}

class EditRequestTableViewController: UITableViewController {
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: ImageCollectionView!
    
    weak var delegate: EditRequestTableViewDelegate?
    
    let picker = UIImagePickerController()
    
    var request: NBRequest?
    var mode: RequestDetailTableViewMode = .none
    var photos: [NBPhoto] = []
    var photosToRemove: [NBPhoto] = []
    
    var itemNameText: String? {
        get {
            return itemName.text
        }
        set {
            itemName.text = newValue
        }
    }
    
    var desc: String? {
        get {
            return descriptionText.text
        }
        set {
            descriptionText.text = newValue
        }
    }
    
    var rent: RequestType {
        get {
            //this can be better, simply make an initializer for enum to do this.... later
            if let rental = rentLabel.text {
                switch rental {
                case "rent":
                    return RequestType.renting
                case "buy":
                    return RequestType.buying
                case "loan":
                    return RequestType.loaning
                case "sell":
                    return RequestType.selling
                default:
                    return RequestType.none
                }
            }
            return RequestType.none
        }
        set {
            rentLabel.text = newValue.rawValue.replacingOccurrences(of: "ing", with: "")
        }
    }
    
    var isMyRequest: Bool {
        get {
            return request?.isMyRequest() ?? false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        saveButton.layer.cornerRadius = 4
        saveButton.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        saveButton.layer.borderWidth = 1.0
        saveButton.clipsToBounds = true
        
        closeButton.layer.cornerRadius = 4
        closeButton.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.clipsToBounds = true
        
        if let request = request {
            loadFields(request: request)
        }
    }
    
    func loadFields(request: NBRequest) {
        itemNameText = request.itemName ?? "<ITEM>"
        desc = request.desc ?? "<DESCRIPTION>"
        rent = request.requestType
        loadPhotos(photoStringArray: request.photos)
    }
    
    func loadPhotos(photoStringArray: [String]) {
        for photoString in photoStringArray {
            let pictureURL = "https://s3.amazonaws.com/nearbyappphotos/\(photoString)"
            print(pictureURL)
            NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureURL, completionHandler: { (image, error) in
                print("done")
                guard error == nil else {
                    print(error!)
                    return
                }
                let photo = NBPhoto(image: image)
                photo.photoString = photoString
                self.photos.append(photo)
                self.collectionView.reloadData()
            })
        }
    }

    // should we create a new request? or at least make a copy?
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let req = self.request
        req?.itemName = itemNameText
        req?.desc = desc
        
        let photoStringArray = AWSManager.sharedInstance.photoActions(photos: photos)
        req?.photos = photoStringArray
        AWSManager.sharedInstance.photoActions(photos: photosToRemove)
        
        self.delegate?.edited(req)
        self.navigationController?.popViewController(animated: true)
    }
    
    // should we create a new request? or at least make a copy?
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        let req = self.request
        let date = Date()
        let calendar = Calendar.current
        calendar.component(.hour, from: date)
        calendar.component(.minute, from: date)
        let dateInt = Int64((date.timeIntervalSince1970 * 1000.0).rounded())
        req?.expireDate = dateInt
        self.delegate?.closed(req)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension EditRequestTableViewController: ImageCollectionViewDelegate, UICollectionViewDataSource {
    
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
            self.chooserPhoto()
        }
        alertController.addAction(chooserAction)
        
        self.present(alertController, animated: true) {
        }
        
    }
    
    func chooserPhoto() {
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
            let removePhoto = self.photos.remove(at: index)
            if removePhoto.awsActionType != .upload {
                removePhoto.awsActionType = .delete
                self.photosToRemove.append(removePhoto)
            }
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

extension EditRequestTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let photo = NBPhoto(image: chosenImage)
        photo.awsActionType = .upload
        photos.append(photo)
        self.collectionView.reloadData()
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

