//
//  HistoryResponseTableViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 1/12/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class HistoryResponseTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var responseStateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
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
            messageLabel.frame.size = CGSize(width: 288, height: 20) // reset, this need to be dynamic
            messageLabel.sizeToFit()
        }
    }
    
    var attributedMessage: NSAttributedString? {
        get {
            return messageLabel.attributedText
        }
        set {
            messageLabel.attributedText = newValue
            messageLabel.frame.size = CGSize(width: 288, height: 20) // reset, this need to be dynamic
            messageLabel.sizeToFit()
        }
    }
    
    var state: String? {
        get {
            return responseStateLabel.text
        }
        set {
            if let newValue = newValue {
                responseStateLabel.text = " \(newValue) ".uppercased()
            }
            else {
                responseStateLabel.text = " NO STATE "
            }
            responseStateLabel.sizeToFit()
        }
    }
    
    var stateColor: UIColor? {
        get {
            return responseStateLabel.backgroundColor
        }
        set {
            responseStateLabel.backgroundColor = newValue
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
//        userImageView.clipsToBounds = true
        
        responseStateLabel.layer.cornerRadius = responseStateLabel.frame.size.height / 8
        responseStateLabel.clipsToBounds = true
    }
    
}
