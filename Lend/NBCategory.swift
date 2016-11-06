//
//  NBCategory.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/17/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NBCategory: ResponseJSONObjectSerializable {
    
    var name: String?
    var id: String?
    // examples
    
    required init?(json: SwiftyJSON.JSON) {
        self.name = json["name"].string
        self.id = json["id"].string
    }
    
    init(test: Bool) {
        if test {
            self.name = "Appliance"
            self.id = "0"
        }
    }

    func toString() -> String {
        return "name: \(name)" +
            " id: \(id)\n"
    }
    
    func toJSON() -> [String: AnyObject] {
        var json = [String: AnyObject]()
        if let name = name {
            json["name"] = name as AnyObject?
        }
        if let id = id {
            json["id"] = id as AnyObject?
        }
        return json
    }
    
}

extension NBCategory {
    
    static func fetchCategoryById(_ id: String, completionHandler: @escaping (Result<[NBCategory]>) -> Void) {
        Alamofire.request(CategoriesRouter.getCategories())
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
    static func fetchCategories(_ completionHandler: @escaping (Result<[NBCategory]>) -> Void) {
        Alamofire.request(CategoriesRouter.getCategories())
            .responseArray { response in
                completionHandler(response.result)
        }
    }
    
    static func addCategory(_ category: NBCategory, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(CategoriesRouter.createCategory(category.toJSON())).response { response in
            completionHandler(response.error as NSError?)
        }
    }
    
}
