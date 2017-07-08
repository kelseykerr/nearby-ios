//
//  UIStory.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


extension UIStoryboard {
    
    //eventually send enum instead of each view having it's own method
    
    static func getViewController(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return viewController
    }
        
    static func getLoginVC() -> LoginViewController {
        return getViewController(identifier: "LoginViewController") as! LoginViewController
    }
    
    static func getEditRequestNavVC() -> UINavigationController {
        return getViewController(identifier: "NewRequestNavigationController") as! UINavigationController
    }
    
    static func getDetailRequestVC() -> UIViewController {
        return getViewController(identifier: "RequestDetailTableViewController")
    }
    
}
