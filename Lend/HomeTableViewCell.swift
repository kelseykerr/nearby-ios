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
    @IBOutlet var rentLabel: UILabel!
    
    var rent: String {
        get {
            return rentLabel.text!
        }
        set {
            rentLabel.text = newValue
        }
    }
    
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
        
        rentLabel.layer.cornerRadius = rentLabel.frame.size.height / 2
        rentLabel.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
