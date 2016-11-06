//
//  NearbyAPIManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/5/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//MOVED MOST OF WHAT WAS IN HERE TO MODELS
class NearbyAPIManager {
    
    static let sharedInstance = NearbyAPIManager()
    
    // is there a way to clear part of cache instead?
    func clearCache() -> Void {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()
    }
    

//    func fetchRequests(latitude: Double, longitude: Double, radius: Double, completionHandler: (Result<[NBRequest], NSError>) -> Void) {
//        Alamofire.request(RequestsRouter.GetRequests(latitude, longitude, radius))
//            .responseArray { response in
//                completionHandler(response.result)
//        }
//    }
//    
//    func fetchRequest(id: String, completionHandler: (Result<NBRequest, NSError>) -> Void) {
//        Alamofire.request(RequestsRouter.GetRequest(id))
//            .responseObject { response in
//                completionHandler(response.result)
//        }
//    }
//    
//    //maybe send response back in completionHandler
//    func removeRequest(req: NBRequest, completionHandler: (NSError?) -> Void) {
////        print("id: \(req.id)")
//        Alamofire.request(RequestsRouter.DeleteRequest(req.id!)).response { (request, response, data, error) in
//            completionHandler(error)
//        }
//    }
//    
//    //send id or request back
//    func addRequest(req: NBRequest, completionHandler: (NSError?) -> Void) {
//        Alamofire.request(RequestsRouter.CreateRequest(req.toJSON())).response { (request, response, data, error) in
////            print(request)
//            completionHandler(error)
//        }
//    }
//    
//    func editRequest(req: NBRequest, completionHandler: (NSError?) -> Void) {
////        print("id: \(req.id!)")
////        print(SwiftyJSON.JSON(req.toJSON()))
////        print(RequestsRouter.EditRequest(req.id!, req.toJSON()).URLRequest)
//        Alamofire.request(RequestsRouter.EditRequest(req.id!, req.toJSON())).response { (request, response, data, error) in
////            print("request:")
////            print(request)
////            print("data:")
////            print(SwiftyJSON.JSON(data!))
////            print("error:")
////            print(error)
////            print("response:")
////            print(response)
//            completionHandler(error)
//        }
//    }

}
