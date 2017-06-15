//
//  AWSManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 6/9/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import AWSCognito
import AWSS3


enum AWSActionType {
    case delete
    case upload
    case none
}


class AWSManager {
    
    static let sharedInstance = AWSManager()
    
    let bucketName = "nearbyappphotos"
    var transferManager: AWSS3TransferManager!
    
    init() {
        transferManager = AWSS3TransferManager.default()
    }
    
    func photoActions(photos: [NBPhoto]) -> [String] {
        var photoStringArray: [String] = []
        for photo in photos {
            if photo.awsActionType == .upload {
                let photoString = uploadPhoto(photo: photo)
                print("uploading: \(photoString)")
                photoStringArray.append(photoString)
                photo.photoString = photoString
            }
            else if photo.awsActionType == .delete {
                print("removing: \(photo.photoString)")
                removePhoto(photo: photo)
            }
            else {
                let photoString = photo.photoString
                print("nothing: \(photoString)")
                photoStringArray.append(photoString)
            }
        }
        return photoStringArray
    }
    
    func uploadPhoto(photo: NBPhoto) -> String {
        let image = photo.image
        let imageUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true) as NSURL
        let key = UUID().uuidString
        let imageName = key
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL = NSURL(fileURLWithPath: documentDirectory)
        let localPath = photoURL.appendingPathComponent(imageName)
        
        do {
            try UIImageJPEGRepresentation(image!, 0.2)?.write(to: localPath!)
            print("file saved")
        } catch {
            print("error saving file")
        }
        
        let uploadingFileURL = localPath!
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = bucketName
        uploadRequest?.key = key
        uploadRequest?.body = uploadingFileURL
        uploadRequest?.acl = AWSS3ObjectCannedACL.publicRead
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(key) Error: \(error)")
                    }
                } else {
                    print("Error uploading: \(key) Error: \(error)")
                }
                return nil
            }
            
            _ = task.result
            print("Upload complete for: \(key)")
            return nil
        })
        return key
    }
    
    func removePhoto(photo: NBPhoto) {
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:c505ec70-228a-498f-87e5-d9035d10a8e3")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let s3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = self.bucketName
        deleteObjectRequest?.key = photo.photoString
        s3.deleteObject(deleteObjectRequest!).continueWith { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            print("Deleted successfully.")
            return nil
        }
    }
    
    func downloadPhoto(key: String, completionBlock: @escaping (UIImage) -> Void) {
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key)
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest?.bucket = bucketName
        downloadRequest?.key = key
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading: \(key) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(key) Error: \(error)")
                }
                return nil
            }
            //            print("Download complete for: \(key)")
            let downloadingFileURL: NSURL = task.result!.body as! NSURL
            let image = UIImage(contentsOfFile: downloadingFileURL.path!)
            completionBlock(image!)
            return nil
        })
    }
}
