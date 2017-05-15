//
//  HomeTableViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 12/10/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    var time: String {
        get {
            return timeLabel.text!
        }
        set {
            timeLabel.text = newValue
        }
    }
    
    var distance: String {
        get {
            return distanceLabel.text!
        }
        set {
            distanceLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        distanceLabel.layer.cornerRadius = distanceLabel.frame.size.height / 2
        distanceLabel.clipsToBounds = true
    }

}
