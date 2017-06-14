//
//  PhotoCollectionViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 6/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let press = UILongPressGestureRecognizer(target: self, action: "pressed")
    }
    
    func pressed() {
        let collectionView = self.superview
        print("collection cell held")
    }
}
