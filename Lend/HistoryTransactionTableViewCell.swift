//
//  HistoryRequestTableViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit


class HistoryTransactionTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var historyStateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var exchangeTimeLabel: UILabel!
    @IBOutlet var exchangeLocationLabel: UILabel!
    @IBOutlet var timeTitleLabel: UILabel!
    @IBOutlet var locationTitleLabel: UILabel!
    
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
            return historyStateLabel.text
        }
        set {
            if let newValue = newValue {
                historyStateLabel.text = " \(newValue) ".uppercased()
            }
            else {
                historyStateLabel.text = " NO STATE "
            }
            historyStateLabel.sizeToFit()
        }
    }
    
    var stateColor: UIColor? {
        get {
            return historyStateLabel.backgroundColor
        }
        set {
            historyStateLabel.backgroundColor = newValue
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
    
    var exchangeTime: String? {
        get {
            return exchangeTimeLabel.text
        }
        set {
            exchangeTimeLabel.isHidden = (newValue == nil)
            timeTitleLabel.isHidden = (newValue == nil)
            exchangeTimeLabel.text = newValue
        }
    }
    
    var exchangeLocation: String? {
        get {
            return exchangeLocationLabel.text
        }
        set {
            exchangeLocationLabel.isHidden = (newValue == nil)
            locationTitleLabel.isHidden = (newValue == nil)
            exchangeLocationLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        historyStateLabel.layer.cornerRadius = historyStateLabel.frame.size.height / 8
        historyStateLabel.clipsToBounds = true
        
        timeTitleLabel.isHidden = true
        locationTitleLabel.isHidden = true
    }
    
}
