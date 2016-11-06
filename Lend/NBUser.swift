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
        }
    }

    func toString() -> String {
        return "firstName: \(self.firstName)" +
               " lastName: \(self.lastName)" +
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
