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
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlertMessage(message: String) {
        let alert = Utils.createErrorAlert(errorMessage: message)
        self.present(alert, animated: true, completion: nil)
    }
    
}
