//
//  NBUser.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/17/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// token?
class NBUser: ResponseJSONObjectSerializable {
    
    var firstName: String?
    var lastName: String?
    var userId: String?
    var fullName: String?
    var id: String?
    
    var email: String?
    var phone: String?
    var address: String?
    var addressLine2: String?
    var city: String?
    var state: String?
    var zip: String?
    
    var homeLongitude: Float?
    var homeLatitude: Float?
    var newRequestNotificationsEnabled: Bool?
    var notificationRadius: Float?
//        "notificationKeywords": [
//        "string"
//        ],
    var currentLocationNotifications: Bool?
    var homeLocationNotifications: Bool?
    var merchantId: String?
    var merchantStatus: String?
    var merchantStatusMessage: String?
    var customerId: String?
    var isPaymentSetup: Bool?
    var customerStatus: String?
    var dateOfBirth: String?
    var bankAccountNumber: String?
    var bankRoutingNumber: String?
    var fundDestination: String?
    var tosAccepted: Bool
    var paymentMethodNonce: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.firstName = json["firstName"].string
        self.lastName = json["lastName"].string
        self.userId = json["userId"].string
        self.fullName = json["fullName"].string
        self.id = json["id"].string
        self.email = json["email"].string
        self.phone = json["phone"].string
        self.address = json["address"].string
        self.addressLine2 = json["addressLine2"].string
        self.city = json["city"].string
        self.state = json["state"].string
        self.zip = json["zip"].string

        self.homeLongitude = json["homeLongitude"].float
        self.homeLatitude = json["homeLatitude"].float
        self.newRequestNotificationsEnabled = json["newRequestNotificationsEnabled"].bool
        self.notificationRadius = json["notificationRadius"].float

        self.currentLocationNotifications = json["currentLocationNotifications"].bool
        self.homeLocationNotifications = json["homeLocationNotifications"].bool
        self.merchantId = json["merchantId"].string
        self.merchantStatus = json["merchantStatus"].string
        self.merchantStatusMessage = json["merchantStatusMessage"].string
        self.customerId = json["customerId"].string
        self.isPaymentSetup = json["isPaymentSetup"].bool
        self.customerStatus = json["customerStatus"].string
        self.dateOfBirth = json["dateOfBirth"].string
        self.bankAccountNumber = json["bankAccountNumber"].string
        self.bankRoutingNumber = json["bankRoutingNumber"].string
        self.fundDestination = json["fundDestination"].string
        self.tosAccepted = json["tosAccepted"].bool ?? false
        self.paymentMethodNonce = json["paymentMethodNonce"].string
    }
    
    init(test: Bool) {
        if test {
            self.firstName = "Demo"
            self.lastName = "App"
            self.userId = "190639591352732"
            self.fullName = "Demo App"
            self.id = "57b5de1e46e0fb000175e3d5"
            self.email = "k@nearby.com"
            self.phone = "555-555-5555"
            self.address = "1234 Lender's Way"
            self.addressLine2 = "Apt 7"
            self.city = "Burlingame"
            self.state = "CA"
            self.zip = "94010"
            
//            self.homeLongitude = 0.0
//            self.homeLatitude = 0.0
//            self.newRequestNotificationsEnabled = true
//            self.notificationRadius = 1.0
//            
//            self.currentLocationNotifications = true
//            self.homeLocationNotifications = true
//            self.merchantId = ""
//            self.merchantStatus = json["merchantStatus"].string
//            self.merchantStatusMessage = json["merchantStatusMessage"].string
//            self.customerId = json["customerId"].string
//            self.isPaymentSetup = json["isPaymentSetup"].bool
//            self.customerStatus = json["customerStatus"].string
//            self.dateOfBirth = json["dateOfBirth"].string
//            self.bankAccountNumber = json["bankAccountNumber"].string
//            self.bankRoutingNumber = json["bankRoutingNumber"].string
//            self.fundDestination = json["fundDestination"].string
//            self.paymentMethodNonce = json["paymentMethodNonce"].string
        }
        self.tosAccepted = false
    }

    func toString() -> String {
        return "firstName: \(self.firstName)" +
               " lastName: \(self.lastName)" +
               " paymentMethodNonce: \(self.paymentMethodNonce)" +
               " userId: \(self.userId)" +
               " fullName: \(self.fullName)" +
               " id: \(self.id)" +
               " email: \(self.email)" +
               " phone: \(self.phone)" +
               " address: \(self.address)" +
               " addressLine2: \(self.addressLine2)" +
               " city: \(self.city)" +
               " state: \(self.state)" +
               " zip: \(self.zip)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let firstName = firstName {
            json["firstName"] = firstName as AnyObject?
        }
        if let lastName = lastName {
            json["lastName"] = lastName as AnyObject?
        }
        if let userId = userId {
            json["userId"] = userId as AnyObject?
        }
        if let fullName = fullName {
            json["fullName"] = fullName as AnyObject?
        }
        if let id = id {
            json["id"] = id as AnyObject?
        }
        if let email = email {
            json["email"] = email as AnyObject?
        }
        if let phone = phone {
            json["phone"] = phone as AnyObject?
        }
        if let address = address {
            json["address"] = address as AnyObject?
        }
        if let addressLine2 = addressLine2 {
            json["addressLine2"] = addressLine2 as AnyObject?
        }
        if let city = city {
            json["city"] = city as AnyObject?
        }
        if let state = state {
            json["state"] = state as AnyObject?
        }
        if let zip = zip {
            json["zip"] = zip as AnyObject?
        }
        
        if let homeLongitude = homeLongitude {
            json["homeLongitude"] = homeLongitude as AnyObject?
        }
        if let homeLatitude = homeLatitude {
            json["homeLatitude"] = homeLatitude as AnyObject?
        }
        if let newRequestNotificationsEnabled = newRequestNotificationsEnabled {
            json["newRequestNotificationsEnabled"] = newRequestNotificationsEnabled as AnyObject?
        }
        if let notificationRadius = notificationRadius {
            json["notificationRadius"] = notificationRadius as AnyObject?
        }
        
        if let currentLocationNotifications = currentLocationNotifications {
            json["currentLocationNotifications"] = currentLocationNotifications as AnyObject?
        }
        if let homeLocationNotifications = homeLocationNotifications {
            json["homeLocationNotifications"] = homeLocationNotifications as AnyObject?
        }
        if let merchantId = merchantId {
            json["merchantId"] = merchantId as AnyObject?
        }
        if let merchantStatus = merchantStatus {
            json["merchantStatus"] = merchantStatus as AnyObject?
        }
        if let merchantStatusMessage = merchantStatusMessage {
            json["merchantStatusMessage"] = merchantStatusMessage as AnyObject?
        }
        if let customerId = customerId {
            json["customerId"] = customerId as AnyObject?
        }
        if let isPaymentSetup = isPaymentSetup {
            json["isPaymentSetup"] = isPaymentSetup as AnyObject?
        }
        if let customerStatus = customerStatus {
            json["customerStatus"] = customerStatus as AnyObject?
        }
        if let dateOfBirth = dateOfBirth {
            json["dateOfBirth"] = dateOfBirth as AnyObject?
        }
        if let bankAccountNumber = bankAccountNumber {
            json["bankAccountNumber"] = bankAccountNumber as AnyObject?
        }
        if let bankRoutingNumber = bankRoutingNumber {
            json["bankRoutingNumber"] = bankRoutingNumber as AnyObject?
        }
        if let fundDestination = fundDestination {
            json["fundDestination"] = fundDestination as AnyObject?
        }
//        if let tosAccepted = tosAccepted {
            json["tosAccepted"] = tosAccepted as AnyObject?
//        }
        if let paymentMethodNonce = paymentMethodNonce {
            json["paymentMethodNonce"] = paymentMethodNonce as AnyObject?
        }
        
        return json
    }

}

extension NBUser {
    
    static func fetchSelf(_ completionHandler: @escaping (Result<NBUser>) -> Void) {
        Alamofire.request(UsersRouter.getSelf())
            .responseObject { response in
                completionHandler(response.result)
        }
    }
    
    static func fetchSelfRequests(_ completionHandler: @escaping (Result<[NBRequest]>) -> Void) {
        Alamofire.request(UsersRouter.getSelfRequests())
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
    static func editSelf(_ user: NBUser, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(UsersRouter.editSelf(user.toJSON())).response { response in
//            print("======== BEGIN ========")
//            print(JSON(user.toJSON()))
//            print(response)
//            print("======== END ========")
            completionHandler(response.error as NSError?)
        }
    }
    
    static func fetchUser(_ id: String, completionHandler: @escaping (Result<NBUser>) -> Void) {
        Alamofire.request(UsersRouter.getUser(id))
            .responseObject { response in
                completionHandler(response.result)
        }
    }
    
}
