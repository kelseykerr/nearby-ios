//
//  HistoryTransactionTableViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 3/12/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class HistoryTransactionTableViewCell: UITableViewCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userImageView2: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var historyStateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        userImageView2.layer.cornerRadius = userImageView2.frame.size.width / 2
        userImageView2.clipsToBounds = true
        
        historyStateLabel.layer.cornerRadius = historyStateLabel.frame.size.height / 2
        historyStateLabel.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
