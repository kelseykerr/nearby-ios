//
//  Utils.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/15/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation
import MBProgressHUD


class Utils {
    
    static let dateFormatter = DateFormatter()
    
    static func is32Bit() -> Bool {
        return MemoryLayout<Int>.size == 4
    }
    
    static func is64Bit() -> Bool {
        return MemoryLayout<Int>.size == 8
    }
    
    static func secondsToEnglish(seconds: Int) -> String {
        if seconds < 60 { // less than a min
            return "\(seconds)s"
        }
        else if seconds < 3600 { // less than an hour
            return "\(seconds / 60)m"
        }
        else if seconds < 60 * 60 * 24 { // less than a day
            return "\(seconds / (60 * 60))h"
        }
        else {
            return "\(seconds / (60 * 60 * 24))d"
        }
    }

    static func createErrorAlert(errorMessage: String?) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: "\(errorMessage ?? "No error message")", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
    
    static func createServerErrorAlert(errorCode: Int, errorMessage: String?) -> UIAlertController {
        let alert = createErrorAlert(errorMessage: "\(errorCode): \(errorMessage ?? "No error message")")
        return alert
    }
    
    static func createServerErrorAlert(error: NSError?) -> UIAlertController {
        let errorMessage = error?.domain
        let errorCode = error?.code ?? -999
        let alert = createServerErrorAlert(errorCode: errorCode, errorMessage: errorMessage)
        return alert
    }
    
    static func createProgressHUD(view: UIView, text: String?) -> MBProgressHUD {
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD.mode = MBProgressHUDMode.indeterminate
        progressHUD.label.text = text
        progressHUD.contentColor = UIColor.white
        progressHUD.bezelView.color = UIColor.darkGray
        return progressHUD
    }
    
    static func dateIntToFormattedString(time: Int64) -> String {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let epoch = (time) / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}
