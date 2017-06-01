//
//  NBColor.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/13/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red) / 255
        let newGreen = CGFloat(green) / 255
        let newBlue = CGFloat(blue) / 255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    static let nbRed = UIColor(red: 233, green: 88, blue: 78)
    static let nbYellow = UIColor(red: 255, green: 226, blue: 77)
    static let nbGreen = UIColor(red: 78, green: 236, blue: 207)
    //#4EE2EC = 00E3ED
    //static let nbBlue = UIColor(red: 0, green: 227, blue: 237)
    static let nbBlue = UIColor(netHex: 0x00E3ED)
    static let nbTurquoise = UIColor(netHex: 0x00E3ED)
    
    static let fern = UIColor(netHex: 0x61BD6D)
    static let mountainMedow = UIColor(netHex: 0x19B193)
    static let pictonBlue = UIColor(netHex: 0x4DA0C3)
    static let mariner = UIColor(netHex: 0x2979BB)
    static let wisteria = UIColor(netHex: 0x664681)
    static let chambray = UIColor(netHex: 0x3E4B69)
    static let chateauGreen = UIColor(netHex: 0x41A85F)
    static let persianGreen = UIColor(netHex: 0x01A885)
    static let curiousBlue = UIColor(netHex: 0x3D8EB9)
    static let denim = UIColor(netHex: 0x2969B0)
    static let blueGem = UIColor(netHex: 0x553982)
    static let blueWhale = UIColor(netHex: 0x28324E)
    static let energy = UIColor(netHex: 0xF7DA64)
    static let neonCarrot = UIColor(netHex: 0xFBA026)
    static let terraCotta = UIColor(netHex: 0xEB6B56)
    static let cinnabar = UIColor(netHex: 0xE14938)
    static let almondFrost = UIColor(netHex: 0xA38F84)
    static let whiteSmoke = UIColor(netHex: 0xEFEFEF)
    static let turbo = UIColor(netHex: 0xEBB91B)
    static let sun = UIColor(netHex: 0xF37934)
    static let valencia = UIColor(netHex: 0xD14841)
    static let wellRead = UIColor(netHex: 0xB8302F)
    static let ironGray = UIColor(netHex: 0x75706B)
    static let iron = UIColor(netHex: 0xD1D5D8)
}
