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
    var postDate: String?
    var expireDate: String?
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
        self.postDate = json["postDate"].string
        self.expireDate = json["expireDate"].string
        self.category = NBCategory(json: json["category"])
        self.rental = json["rental"].bool
        self.desc = json["description"].string
        self.id = json["id"].string
        self.type = json["type"].string
        self.status = json["status"].string
    }
    
    init(test: Bool) {
        if test {
//            self.user = NBUser(test: true)
            self.itemName = "Microwave"
            self.latitude = 84.5
            self.longitude = 75.6
            self.postDate = "2016-08-18T06:04:25.342Z"
            self.expireDate = "2017-08-18T06:04:25.342Z"
//            self.category = NBCategory(test: true)
            self.rental = true
            self.desc = "This is 900 watts"
            self.id = "1234"
            self.type = "item"
            self.status = "UNKNOWN"
        }
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
        Alamofire.request(RequestsRouter.createRequest(req.toJSON())).response { response in
            completionHandler(response.error as NSError?)
        }
    }
    
    static func editRequest(_ req: NBRequest, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(RequestsRouter.editRequest(req.id!, req.toJSON())).response { response in
            completionHandler(response.error as NSError?)
        }
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
            return self.desc ?? "No description"
        }
    }
    
}
