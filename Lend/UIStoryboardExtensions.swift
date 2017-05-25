//
//  UIStory.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


extension UIStoryboard {
    
    static func getViewController(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return viewController
    }
    
    static func getEditRequestNavVC() -> UINavigationController {
        return getViewController(identifier: "NewRequestNavigationController") as! UINavigationController
    }
    
    static func getDetailRequestVC() -> UIViewController {
        return getViewController(identifier: "RequestDetailTableViewController")
    }
    
}
