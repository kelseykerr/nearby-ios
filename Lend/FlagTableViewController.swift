//
//  FlagTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 5/15/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit


protocol FlagTableViewDelegate: class {
    
    func flagged(_ flag: NBFlag?) // return type with it
    
    func cancelled()
    
}

enum FlagTableViewMode {
    case request(String) // requestId
    case response(String, String) // requestId, responseId
    case user(String) // userId
    case none
}

class FlagTableViewController: UITableViewController {

    @IBOutlet var requestIdLabel: UILabel!
    @IBOutlet var notesView: UITextView!
    @IBOutlet var flagButton: UIButton!

    weak var delegate: FlagTableViewDelegate?
    
    var id: String? {
        get {
            return requestIdLabel.text
        }
        set {
            requestIdLabel.text = newValue
        }
    }

    
    var mode: FlagTableViewMode = .none
    
//    var userId: String?
//    var requestId: String?
    
    var notes: String? {
        get {
            return notesView.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flagButton.layer.cornerRadius = flagButton.frame.size.height / 16
        flagButton.clipsToBounds = true
        
        if case .user = mode {
            self.title = "Block"
            self.flagButton.setTitle("Block", for: .normal)
        }
        
        loadInitialData()
    }
    
    func loadInitialData() {
//        if let id = id {
//            self.requestIdLabel.text = id
//        }
        
        switch mode {
        case .request(let requestId):
            self.id = requestId
        case .response(let _, let responseId):
            self.id = responseId
        case .user(let userId):
            self.id = userId
        case .none:
            self.id = "N/A"
        }
    }
    
    func createFlag() -> NBFlag? {
        if let id = id {
            return NBFlag(id: id, reporterNotes: notes)
        }
        return nil
    }

//    func createUserFlag() -> NBFlag? {
//        if let userId = userId {
//            return NBFlag(id: userId, reporterNotes: notes)
//        }
//        return nil
//    }
    
    @IBAction func flagButtonPressed(_ sender: UIButton) {
        if let flag = createFlag() {
            switch mode {
            case .request(let requestId):
                print("request flagged: \(requestId)")
                NBFlag.flagRequest(requestId: requestId, flag: flag, completionHandler: { error in
                    self.delegate?.flagged(flag)
                })
            case .response(let requestId, let responseId):
                print("response flagged: \(requestId) \(responseId)")
                NBFlag.flagResponse(requestId: requestId, responseId: responseId, flag: flag, completionHandler: { error in
                    self.delegate?.flagged(flag)
                })
            case .user(let userId):
                print("user blocked: \(userId)")
                NBFlag.blockUser(userId: userId, flag: flag, completionHandler: { error in
                    self.delegate?.flagged(flag)
                })
            case .none:
                print("Do nothing")
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func blockUserButtonPressed(_ sender: UIButton) {
//        if let flag = createUserFlag() {
//            NBFlag.blockUser(id: userId, flag: flag, completionHandler: { error in
//                self.delegate?.flagged(flag)
//            })
//        }
//
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
}
