//
//  UIViewControllerExtension.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/16/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

}
