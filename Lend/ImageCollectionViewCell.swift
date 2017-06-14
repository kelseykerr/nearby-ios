//
//  ImageCollectionViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 6/9/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoImageView.layer.cornerRadius = 4
        photoImageView.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        photoImageView.layer.borderWidth = 1.0
        photoImageView.clipsToBounds = true

        let press = UILongPressGestureRecognizer(target: self, action: #selector(ImageCollectionViewCell.pressed))
        self.addGestureRecognizer(press)
        
    }
    
    func pressed() {
        if let collectionView = self.superview as? ImageCollectionView {
            collectionView.cellSelectedToBeRemoved(cell: self)
        }
    }
    
}
