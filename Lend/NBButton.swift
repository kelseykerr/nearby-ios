//
//  UIButtonExtensions.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 6/16/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit


class NBButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
    }
}
