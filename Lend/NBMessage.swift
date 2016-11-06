//
//  NBMessage.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/3/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import SwiftyJSON

class NBMessage: ResponseJSONObjectSerializable {
    
    var timeSent: String?
    var content: String?
    var senderId: String?
    
    required init?(json: SwiftyJSON.JSON) {
        self.timeSent = json["timeSent"].string
        self.content = json["content"].string
        self.senderId = json["senderId"].string
    }
    
    init(test: Bool) {
        if test {
            self.timeSent = "timeSent"
            self.content = "content"
            self.senderId = "senderId"
        }
    }
    
    func toString() -> String {
        return "timeSent: \(timeSent)" +
            " content: \(content)" +
            " senderId: \(senderId)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let timeSent = timeSent {
            json["timeSent"] = timeSent as AnyObject?
        }
        if let content = content {
            json["content"] = content as AnyObject?
        }
        if let senderId = senderId {
            json["senderId"] = senderId as AnyObject?
        }
        return json
    }
    
}
