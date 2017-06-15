//
//  NBPhoto.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 6/8/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import NYTPhotoViewer

class NBPhoto: NSObject, NYTPhoto, ResponseJSONObjectSerializable {

    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    var awsActionType = AWSActionType.none
    var photoString = ""
    
    required init?(json: SwiftyJSON.JSON) {
//        self.firstName = json["firstName"].string
    }
    
    init(image: UIImage?) {
        self.image = image
    }
    
    func toString() -> String {
        return "photo"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
//        if let firstName = firstName {
//            json["firstName"] = firstName as AnyObject?
//        }
        
        return json
    }
    
}
