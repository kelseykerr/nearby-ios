//
//  NewRequestTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class NewRequestTableViewController: UITableViewController {

    @IBOutlet var itemNameTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var buyRentSegmentedControl: UISegmentedControl!

    var itemName: String? {
        get {
            return itemNameTextField.text
        }
    }
    
    var desc: String? {
        get {
            return descriptionTextView.text
        }
    }
    
    var rent: Bool {
        get {
            return buyRentSegmentedControl.selectedSegmentIndex == 1
        }
    }

    var selectedCategory: NBCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushCategorySelectionViewController" {
            let categoryVC = segue.destination as! CategorySelectionTableViewController
            categoryVC.delegate = self
        }
    }
    
}

extension NewRequestTableViewController: CategorySelectionTableViewDelegate {
    
    func categorySelected(_ category: NBCategory) {
        print("category: \(category.name!)")
        self.selectedCategory = category
        self.categoryLabel.text = category.name!
        self.navigationController?.popViewController(animated: true)
    }
    
    func selectionCancelled() {
        print("cancelled")
        self.navigationController?.popViewController(animated: true)
    }
}
