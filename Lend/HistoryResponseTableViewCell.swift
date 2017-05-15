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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        responseStateLabel.layer.cornerRadius = responseStateLabel.frame.size.height / 8
        responseStateLabel.clipsToBounds = true
    }
    
}
