//
//  FilterTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 10/19/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import DropDown

protocol FilterTableViewDelegate: class {
    
    func searched() // need to likely send something back...
    
    func cancelled()
}

class FilterTableViewController: UITableViewController {
    
    weak var delegate: FilterTableViewDelegate?
    
    var filter: SearchFilter?
    
    @IBOutlet weak var wantedSwitch: UISwitch!
    @IBOutlet weak var offeredSwitch: UISwitch!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var radiusButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!

    let locationDropDown = DropDown()
    let radiusDropDown = DropDown()
    let sortDropDown = DropDown()
    let textField = UITextField()
    
    @IBOutlet var searchButton: UIButton!
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.locationDropDown,
            self.radiusDropDown,
            self.sortDropDown
        ]
    }()
    
    @IBAction func chooseLocation(_ sender: AnyObject) {
        locationDropDown.show()
    }
    
    @IBAction func chooseRadius(_ sender: AnyObject) {
        radiusDropDown.show()
    }
    
    @IBAction func chooseSort(_ sender: AnyObject) {
        sortDropDown.show()
    }
    
    func setupDefaultDropDown() {
        DropDown.setupDefaultAppearance()
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.customCellConfiguration = nil
        }
    }
    
    func setupDropDowns() {
        setupLocationDropDown()
        setupRadiusDropDown()
        setupSortDropDown()
    }
    
    func setupLocationDropDown() {
        locationDropDown.anchorView = locationButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        locationDropDown.bottomOffset = CGPoint(x: 0, y: locationButton.bounds.height)
        UserManager.sharedInstance.getUser { fetchedUser in
            if (fetchedUser.hasHomeLocation()) {
                // You can also use localizationKeysDataSource instead. Check the docs.
                self.locationDropDown.dataSource = [
                    "current location",
                    "home address"
                ]
            } else {
                // You can also use localizationKeysDataSource instead. Check the docs.
                self.locationDropDown.dataSource = [
                    "current location"
                ]
                self.filter?.searchBy = "current location"
            }
        }
        
        // Action triggered on selection
        locationDropDown.selectionAction = { [unowned self] (index, item) in
            self.locationButton.setTitle(item, for: .normal)
        }
    }
    
    func setupRadiusDropDown() {
        radiusDropDown.anchorView = radiusButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        radiusDropDown.bottomOffset = CGPoint(x: 0, y: radiusButton.bounds.height)
        radiusDropDown.dataSource = [
            ".1 mile radius",
            ".25 mile radius",
            ".5 mile radius",
            "1 mile radius",
            "5 mile radius",
            "10 mile radius"
        ]
        
        // Action triggered on selection
        radiusDropDown.selectionAction = { [unowned self] (index, item) in
            self.radiusButton.setTitle(item, for: .normal)
        }
    }
    
    func setupSortDropDown() {
        sortDropDown.anchorView = sortButton
        sortDropDown.bottomOffset = CGPoint(x: 0, y: sortButton.bounds.height)
        sortDropDown.dataSource = [
            "newest",
            "distance",
            "best match"
        ]
        sortDropDown.selectionAction = { [unowned self] (index, item) in
            self.sortButton.setTitle(item, for: .normal)
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropDowns()
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        view.addSubview(textField)
        
        self.hideKeyboardWhenTappedAround()
        
        searchButton.layer.cornerRadius = 4
        searchButton.layer.borderColor = UIColor(netHex: 0xE2E1DF).cgColor
        searchButton.layer.borderWidth = 1.0
        searchButton.clipsToBounds = true
        
        loadInitialData()
    }
    
    func loadInitialData() {
        if let filter = filter {
            wantedSwitch.setOn(filter.includeWanted, animated: false)
            offeredSwitch.setOn(filter.includeOffered, animated: false)
            sortButton.setTitle(filter.sortBy, for: .normal)
            locationButton.setTitle(filter.searchBy, for: .normal)
            let radiusString = switchRadiusDoubleToText(radius: filter.searchRadius)
            radiusButton.setTitle(radiusString, for: .normal)
        }
    }
    
    func switchRadiusDoubleToText(radius: Double) -> String {
        switch radius {
        case 0.1:
        return ".1 mile radius"
        case 0.25:
        return ".25 mile radius"
        case 0.5:
        return ".5 mile radius"
        case 1:
        return "1 mile radius"
        case 5:
        return "5 mile radius"
        case 10:
        return "10 mile radius"
        default:
        return "1 mile radius"
        }
    }
    
    func switchRadiusTextToDouble(radiusText: String) -> Double {
        switch radiusText {
        case ".1 mile radius":
            return 0.1
        case ".25 mile radius":
            return 0.25
        case ".5 mile radius":
            return 0.5
        case "1 mile radius":
            return 1
        case "5 mile radius":
            return 5
        case "10 mile radius":
            return 10
        default:
            return 1
        }
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        print("FilterTableView::searchButtonPressed")
        
        if let filter = filter {
            filter.includeWanted = wantedSwitch.isOn
            filter.includeOffered = offeredSwitch.isOn
            filter.searchBy = (locationButton.titleLabel?.text) ?? "current location"
            filter.sortBy = (sortButton.titleLabel?.text) ?? "newest"
            let radiusDouble = switchRadiusTextToDouble(radiusText: (radiusButton.titleLabel?.text) ?? "10 mile radius")
            filter.searchRadius = radiusDouble
        }
        
        delegate?.searched()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("FilterTableView::cancelButtonPressed")
        delegate?.cancelled()
        self.dismiss(animated: true, completion: nil)
    }
}
