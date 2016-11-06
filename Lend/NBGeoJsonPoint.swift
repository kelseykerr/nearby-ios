//
//  NBGeoJsonPoint.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/17/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import SwiftyJSON


class NBGeoJsonPoint: ResponseJSONObjectSerializable {
    var type: String?
    var coordinates: String? // Make this some point thingy on the map
    
    required init?(json: SwiftyJSON.JSON) {
        self.type = json["type"].string
        self.coordinates = json["coordinates"].string
    }
    
    init(test: Bool) {
        if test {
            self.type = "string"
            self.coordinates = "string"
        }
    }
    
    func toString() -> String {
        return "type: \(type)" +
            " coordinates: \(coordinates)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let type = type {
            json["type"] = type as AnyObject?
        }
        if let coordinates = coordinates {
            json["coordinates"] = coordinates as AnyObject?
        }
        return json
    }
    
}
