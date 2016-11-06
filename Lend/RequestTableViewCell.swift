//
//  RequestTableViewCell.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 9/28/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        
        context?.setLineWidth(1.0)
        
        context?.move(to: CGPoint(x: 0.0, y: 0.0))
        
        context?.addLine(to: CGPoint(x: self.bounds.width, y: 0))

//        CGContextMoveToPoint(context, 0, self.bounds.height)
//        
//        CGContextAddLineToPoint(context, self.bounds.width, self.bounds.height)
        
        context?.strokePath();
    }

}
