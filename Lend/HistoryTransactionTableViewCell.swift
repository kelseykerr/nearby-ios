//
//  HistoryRequestTableViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

//class InsetLabel: UILabel {
//    let topInset = CGFloat(0)
//    let bottomInset = CGFloat(0)
//    let leftInset = CGFloat(20)
//    let rightInset = CGFloat(20)
//
//    override func drawText(in rect: CGRect) {
//        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
//        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
//    }
//
//    override public var intrinsicContentSize: CGSize {
//        var intrinsicSuperViewContentSize = super.intrinsicContentSize
//        intrinsicSuperViewContentSize.height += topInset + bottomInset
//        intrinsicSuperViewContentSize.width += leftInset + rightInset
//        return intrinsicSuperViewContentSize
//    }
//}

class HistoryTransactionTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var historyStateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var exchangeTimeLabel: UILabel!
    @IBOutlet var exchangeLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        historyStateLabel.layer.cornerRadius = historyStateLabel.frame.size.height / 8
        historyStateLabel.clipsToBounds = true
    }
    
}
