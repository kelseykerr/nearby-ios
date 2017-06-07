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

class AwsManager: NSObject {
    
    static let sharedInstance = AwsManager()
    let bucketName = "nearbyappphotos"
    var credentialProvider: AWSCognitoCredentialsProvider!
    var configuration: AWSServiceConfiguration!
    var transferManager: AWSS3TransferManager!
    var cognitoId: String!

    override init() {
        super.init()
        credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:c505ec70-228a-498f-87e5-d9035d10a8e3")
        configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        transferManager = AWSS3TransferManager.default()
        cognitoId = credentialProvider.identityId
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func UploadPhoto(path: String) {
        let uploadingFileURL = URL(fileURLWithPath: path)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        let key = UUID().uuidString
        uploadRequest?.bucket = bucketName
        uploadRequest?.key = key
        uploadRequest?.body = uploadingFileURL
        
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
    
    func downloadPhoto(key: String) {
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
            print("Download complete for: \(key)")
            _ = task.result
            return nil
            //self.imageView.image = UIImage(contentsOfFile: downloadingFileURL.path)
        })
        
    }
}
