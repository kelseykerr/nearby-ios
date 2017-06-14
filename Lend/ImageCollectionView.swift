//
//  PhotoCollectionView.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 6/14/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


protocol ImageCollectionViewDelegate: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemToRemoveAt indexPath: IndexPath)
    
}

class ImageCollectionView: UICollectionView {
    
    func cellSelectedToBeRemoved(cell: ImageCollectionViewCell) {
        if let indexPath = self.indexPath(for: cell) {
            if let delegate = delegate as? ImageCollectionViewDelegate {
                delegate.collectionView(self, didSelectItemToRemoveAt: indexPath)
            }
        }
    }
    
}
