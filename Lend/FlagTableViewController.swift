//
//  FlagTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 5/15/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit


protocol FlagTableViewDelegate: class {
    
    func flagged(_ flag: NBFlag?)
    
    func cancelled()
    
}

class FlagTableViewController: UITableViewController {

    @IBOutlet var requestIdLabel: UILabel!
    @IBOutlet var notesView: UITextView!
    @IBOutlet var flagButton: UIButton!

    weak var request: NBRequest?
    weak var delegate: FlagTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flagButton.layer.cornerRadius = flagButton.frame.size.height / 16
        flagButton.clipsToBounds = true
        
        loadInitialData()
    }
    
    func loadInitialData() {
        if let request = request {
            self.requestIdLabel.text = request.id
        }
    }
    
    func createFlag() -> NBFlag? {
        if let request = request {
            let notes = notesView.text
            return NBFlag(requestId: request.id!, reporterNotes: notes)
        }
        return nil
    }

    @IBAction func flagButtonPressed(_ sender: UIButton) {
        if let flag = createFlag() {
            NBFlag.flag(flag: flag, completionHandler: { error in
                self.delegate?.flagged(flag)
            })
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
}
