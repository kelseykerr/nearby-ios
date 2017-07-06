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
    
    var userImage: UIImage? {
        get {
            return userImageView.image
        }
        set {
            userImageView.image = newValue
            setNeedsLayout()
        }
    }
    
    var message: String? {
        get {
            return messageLabel.text
        }
        set {
            messageLabel.text = newValue
        }
    }
    
    var attributedMessage: NSAttributedString? {
        get {
            return messageLabel.attributedText
        }
        set {
            messageLabel.attributedText = newValue
        }
    }
    
    var time: String? {
        get {
            return timeLabel.text
        }
        set {
            timeLabel.text = newValue
        }
    }
    
    var distance: String? {
        get {
            return distanceLabel.text
        }
        set {
            distanceLabel.text = newValue
        }
    }
    
}
