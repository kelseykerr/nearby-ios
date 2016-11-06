//
//  DetailViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/23/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    var request: NBRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage(named: "nearby_logo")
        let imageView = UIImageView(image: image)
        
        self.navigationItem.titleView = imageView
        
        self.itemNameLabel.text = request?.itemName
        self.descriptionTextView.text = request?.desc
    
//        testResponse()
    }
    
//    func testResponse() {
//        var response = NBResponse(test: true)
//        response.requestId = request!.id
//        response.sellerId = request!.user?.userId
//        NBResponse.addResponse(response) { error in
//            print(error)
//        }
//    }

}
