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
    
    var credentialProvider: AWSCognitoCredentialsProvider!
    var configuration: AWSServiceConfiguration!
    var transferManger: AWSS3TransferManager!
    var cognitoId: String!

    override init() {
        super.init()
        credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:c505ec70-228a-498f-87e5-d9035d10a8e3")
        configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        transferManger = AWSS3TransferManager.default()
        cognitoId = credentialProvider.identityId
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func UploadPhoto() {
        
    }
}
