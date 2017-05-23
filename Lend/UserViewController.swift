//
//  UserViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 5/21/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    weak var user: NBUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        blockButton.layer.cornerRadius = blockButton.frame.size.height / 16
        blockButton.clipsToBounds = true
        
        messageButton.layer.cornerRadius = messageButton.frame.size.height / 16
        messageButton.clipsToBounds = true
        
        loadInitialData()
    }

    func loadInitialData() {
        if let user = user {
            self.nameLabel.text = user.fullName ?? "<name>"
            
            let city = user.city ?? "<city>"
            let state = user.state ?? "<state>"
            self.infoLabel.text = "\(city), \(state)"
            
            if let pictureUrl = user.imageUrl {
                NearbyAPIManager.sharedInstance.imageFrom(urlString: pictureUrl, completionHandler: { (image, error) in
                    self.userImageView.image = image
                })
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func blockButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
