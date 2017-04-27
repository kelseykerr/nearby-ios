//
//  Utils.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/15/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

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
            return "\(seconds) Secs Ago"
        }
        else if seconds < 60 * 60 { // less than an hour
            return "\(seconds / 60) Mins Ago"
        }
        else if seconds < 60 * 60 * 24 { // less than a day
            return "\(seconds / (60 * 60)) Hours Ago"
        }
        else {
            return "\(seconds / (60 * 60 * 24)) Days Ago"
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
        let errorCode = error?.code
        let alert = createServerErrorAlert(errorCode: errorCode!, errorMessage: errorMessage)
        return alert
    }
    
    static func dateIntToFormattedString(time: Int64) -> String {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let epoch = (time ?? 0) / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
}
