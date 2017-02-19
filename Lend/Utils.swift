//
//  Utils.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/15/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

class Utils {
    
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
    
}
