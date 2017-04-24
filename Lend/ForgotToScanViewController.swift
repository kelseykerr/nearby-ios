//
//  ForgotToScanViewController.swift
//  Nearby
//
//  Created by Kerr, Kelsey on 4/23/17.
//  Copyright © 2017 Iuxta, Inc. All rights reserved.
//

import UIKit

protocol ForgotToScanViewDelegate: class {
    
    func cancelled()
    
}

class ForgotToScanViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet var saveButton: UIButton!
    
    weak var delegate: ForgotToScanViewDelegate?
    var transaction: NBTransaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let time = datePicker.date
        let timeInterval = time.timeIntervalSince1970
        var override = NBExchangeOverride(time: Int64(timeInterval * 1000))
        var t = NBTransaction(test: false)
        t.exchangeOverride = override
        t.returnOverride = override
        t.id = transaction?.id
        print(t.toJSON())
        NBTransaction.createExchangeOverride(id: t.id!, transaction: t) { error in
            print(error)
            if let error = error {
                let alert = Utils.createServerErrorAlert(error: error)
                self.present(alert, animated: true, completion: nil)
            }
            self.dismiss(animated: true, completion: nil)
            //TODO: send back to history page
        }

    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
}

