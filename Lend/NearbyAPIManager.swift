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


enum NearbyAPIManagerError: Error {
    case network(error: Error)
    case apiProvidedError(reason: String)
    case authCouldNot(reason: String)
    case authLost(reason: String)
    case objectSerialization(reason: String)
}

class NearbyAPIManager {
    
    static let sharedInstance = NearbyAPIManager()

    // is there a way to clear part of cache instead?
    func clearCache() -> Void {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()
    }
    
    func imageFrom(urlString: String, completionHandler: @escaping (UIImage?, Error?) -> Void) { let _ = Alamofire.request(urlString).response { dataResponse in
            // use the generic response serializer that returns Data
            guard let data = dataResponse.data else {
                completionHandler(nil, dataResponse.error)
                return
            }
        
            let image = UIImage(data: data)
            completionHandler(image, nil)
        }
    }

}
