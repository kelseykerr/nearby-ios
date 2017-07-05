//
//  NBImageView.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 7/5/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class NBImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }

}
