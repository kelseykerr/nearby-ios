//
//  CategorySelectionTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/31/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol CategorySelectionTableViewDelegate: class {
    
    func categorySelected(_ category: NBCategory)
    
    func selectionCancelled()
}


class CategorySelectionTableViewController: UITableViewController {

    weak var delegate: CategorySelectionTableViewDelegate?
    
    var categories = [NBCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categories = CategoriesManager.sharedInstance.categories
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        cell.textLabel!.text = categories[(indexPath as NSIndexPath).row].name ?? "Something went wrong here."

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[(indexPath as NSIndexPath).row]

        self.delegate?.categorySelected(category)
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.delegate?.selectionCancelled()
    }
}
