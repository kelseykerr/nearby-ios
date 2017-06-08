//
//  AwsManager.swift
//  Nearby
//
//  Created by Kelsey Kerr on 6/6/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import AWSCognito
import AWSS3

class AwsManager {
    
    static let sharedInstance = AwsManager()
    
    let bucketName = "nearbyappphotos"
    var transferManager: AWSS3TransferManager!

    init() {
        transferManager = AWSS3TransferManager.default()
    }
    
    func uploadPhoto(path: URL, key: String) {
        // Delete image.
//        do {
//            try FileManager.default.removeItem(atPath: path)
//        } catch {
//            print(error)
//        }
        
        let uploadingFileURL = path//URL(fileURLWithPath: path)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
//        let key = UUID().uuidString
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
