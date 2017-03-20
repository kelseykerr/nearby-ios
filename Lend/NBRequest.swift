//
//  NBRequest.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/17/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MapKit


class NBRequest: NSObject, ResponseJSONObjectSerializable {
    
    var user: NBUser?
    var itemName: String?
    var latitude: Double?
    var longitude: Double?
    var postDate: Int64?
    var expireDate: Int64?
    var category: NBCategory?
    var rental: Bool?
    var desc: String?
    var id: String?
    var type: String?
    var status: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.user = NBUser(json: json["user"])
        self.itemName = json["itemName"].string
        self.latitude = json["latitude"].double
        self.longitude = json["longitude"].double
        self.postDate = json["postDate"].int64
        self.expireDate = json["expireDate"].int64
        self.category = NBCategory(json: json["category"])
        self.rental = json["rental"].bool
        self.desc = json["description"].string
        self.id = json["id"].string
        self.type = json["type"].string
        self.status = json["status"].string
    }
    
    override init() {
        super.init()
//            self.category = NBCategory(test: true)
    }
    
    func toString() -> String {
        return desc ?? "No description"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let user = user {
            json["user"] = user.toJSON() as AnyObject?
        }
        if let itemName = itemName {
            json["itemName"] = itemName as AnyObject?
        }
        if let latitude = latitude {
            json["latitude"] = latitude as AnyObject?
        }
        if let longitude = longitude {
            json["longitude"] = longitude as AnyObject?
        }
        if let postDate = postDate {
            json["postDate"] = postDate as AnyObject?
        }
        if let expireDate = expireDate {
            json["expireDate"] = expireDate as AnyObject?
        }
        if let category = category {
            if category.id != nil {
                json["category"] = category.toJSON() as AnyObject?
            }
        }
        if let rental = rental {
            json["rental"] = rental as AnyObject?
        }
        if let desc = desc {
            json["description"] = desc as AnyObject?
        }
        if let id = id {
            json["id"] = id as AnyObject?
        }
        if let type = type {
            json["type"] = type as AnyObject?
        }
        if let status = status {
            json["status"] = status as AnyObject?
        }
        return json
    }
    
}

extension NBRequest {
    
    static func fetchRequests(_ latitude: Double, longitude: Double, radius: Double, completionHandler: @escaping (Result<[NBRequest]>) -> Void) {
        Alamofire.request(RequestsRouter.getRequests(latitude, longitude, radius))
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
    static func fetchRequests2(_ latitude: Double, longitude: Double, radius: Double, expired: Bool, includeMine: Bool, searchTerm: String, sort: String, completionHandler: @escaping (Result<[NBRequest]>) -> Void) {
        print(latitude)
        print(longitude)
        print(radius)
        print(expired)
        print(includeMine)
        print(searchTerm)
        print(sort)
        Alamofire.request(RequestsRouter.getRequests2(latitude, longitude, radius, expired, includeMine, searchTerm, sort))
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
    static func fetchRequest(_ id: String, completionHandler: @escaping (Result<NBRequest>) -> Void) {
        Alamofire.request(RequestsRouter.getRequest(id))
            .responseObject { response in
                completionHandler(response.result)
        }
    }
    
    //maybe send response back in completionHandler
    static func removeRequest(_ req: NBRequest, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.deleteRequest(req.id!)).response { response in
//            print(response.error)
            completionHandler(response.error as NSError?)
        }
    }

    //response should have the request with new id
    static func addRequest(_ req: NBRequest, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.createRequest(req.toJSON())).validate(statusCode: 200..<300).responseJSON { response in
            if response.result.error != nil {
                let statusCode = response.response?.statusCode
                let errorMessage = String(data: response.data!, encoding: String.Encoding.utf8)
                let nsError = NSError(domain: errorMessage!, code: statusCode!, userInfo: nil)
                completionHandler(nsError)
            }
            else {
                completionHandler(nil)
            }
        }
    }
    
    static func editRequest(_ req: NBRequest, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.editRequest(req.id!, req.toJSON())).validate(statusCode: 200..<300).responseJSON { response in
            if response.result.error != nil {
                let statusCode = response.response?.statusCode
                let errorMessage = String(data: response.data!, encoding: String.Encoding.utf8)
                let nsError = NSError(domain: errorMessage!, code: statusCode!, userInfo: nil)
                completionHandler(nsError)
            }
            else {
                completionHandler(nil)
            }
        }
    }
    
}

extension NBRequest {
    
    var location: CLLocation? {
        get {
            if let latitude = latitude, let longitude = longitude {
                return CLLocation(latitude: latitude, longitude: longitude)
            }
            return nil
        }
    }
    
    func getDistance(fromLocation: CLLocation) -> Double {
        var distance: Double = -1
        if let location = location {
            distance = location.distance(from: fromLocation) / 1609.344
        }
        return distance
    }
    
    func getDistanceAsString(fromLocation: CLLocation) -> String {
        let distance = getDistance(fromLocation: fromLocation)
        
        if distance < 1 {
            let retStr = String(format: "<1 mile", distance)
            return retStr
        }
        else if distance < 2 {
            let retStr = String(format: "%.0f mile", distance)
            return retStr
        }
        else {
            let retStr = String(format: "%.0f miles", distance)
            return retStr
        }
    }
    
    func getElapsedTime() -> TimeInterval? {
        if let postEpochString = self.postDate {
            let postEpoch = Double(postEpochString) / 1000
            let postDate = Date(timeIntervalSince1970: postEpoch)
            let elapsedSeconds = Date().timeIntervalSince(postDate)
            return elapsedSeconds
        }
        return nil
    }
    
    func getElapsedTimeAsString() -> String {
        let seconds = Int(getElapsedTime()!)
        
        if seconds < 60 { // less than a min
//            return "\(seconds) Secs Ago"
            return "\(seconds)s"
        }
        else if seconds < 3600 { // less than an hour
//            return "\(seconds / 60) Mins Ago"
            return "\(seconds / 60)m"
        }
        else if seconds < 60 * 60 * 24 { // less than a day
//            return "\(seconds / (60 * 60)) Hours Ago"
            return "\(seconds / (60 * 60))h"
        }
        else {
//            return "\(seconds / (60 * 60 * 24)) Days Ago"
            return "\(seconds / (60 * 60 * 24))d"
        }

        return "Should not happen"
    }
    
    func isMyRequest() -> Bool {
        return UserManager.sharedInstance.user?.id == self.user?.id
    }
    
}

extension NBRequest: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        get {
//            print(latitude)
//            print(longitude)
            return CLLocationCoordinate2DMake(latitude!, longitude!)
        }
    }
    
    // never returns nil
    var title: String? {
        get {
            return self.itemName ?? "This is a test"
        }
    }
    
    // never returns nil
    var subtitle: String? {
        get {
            return self.user?.fullName ?? "No description"
        }
    }
    
}
