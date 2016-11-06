//
//  Converter.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/22/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import Foundation

class Converter {
    
    static let MilesToMetersMultiplier = 1609.344
    
    static func metersToMiles(_ meters: Double) -> Double {
        return meters / MilesToMetersMultiplier
    }
    
    static func milesToMeters(_ miles: Double) -> Double {
        return miles * MilesToMetersMultiplier
    }
}
