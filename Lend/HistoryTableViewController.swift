//
//  HistoryTableViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 8/5/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// changed unwind? to use protocols (delegate) instead, for consistency
class HistoryTableViewController: UITableViewController {

    var histories = [NBHistory]()
    var nextPageURLString: String?
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        loadHistories()
        
//        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        }
        
        super.viewWillAppear(animated)
    }
    
    // MARK - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return histories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories[section].responses.count + 1
    }
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10
//    }
//    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.groupTableViewBackgroundColor()
//        return headerView
//    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10
//    }
//    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10
//    }
//    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView()
//        footerView.backgroundColor = UIColor.clear
//        return footerView
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
        
            if let request = getRequest((indexPath as NSIndexPath).section) {
//                cell.textLabel?.text = request.itemName
//                cell.detailTextLabel?.text = request.desc
                
                
                let text = " want to borrow "
                let attrText = NSMutableAttributedString(string: "")
                let boldFont = UIFont.boldSystemFont(ofSize: 17)
                let boldFullname = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
                attrText.append(boldFullname)
                attrText.append(NSMutableAttributedString(string: text))
                
                let boldItemName = NSMutableAttributedString(string: request.itemName!, attributes: [NSFontAttributeName: boldFont])
                attrText.append(boldItemName)
                attrText.append(NSMutableAttributedString(string: "."))
                
                cell.textLabel?.attributedText = attrText
            }
        
//            if !isLoading {
//                let rowsLoaded = requests.count
//                let rowsRemaining = rowsLoaded - indexPath.row
//                let rowsToLoadFromBottom = 5
//                if rowsRemaining <= rowsToLoadFromBottom {
//                    if let nextPage = nextPageURLString {
//                        self.loadRequests(nextPage)
//                    }
//                }
//            }
        
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResponseCell", for: indexPath) as! HistoryResponseTableViewCell
            
            if let response = getResponse(indexPath) {
                let fullname = response.seller?.fullName
///                cell.textLabel?.text = fullname
                
                let price = response.offerPrice!
                let priceType = response.priceType!
///                cell.detailTextLabel?.text = "Type: \(priceType) $\(price)"
                
//                cell.textLabel?.text = "\(fullname!) is offering to lend you coffee for $\(price)."
                
                let text = " is offering to lend it to you for "
                let attrText = NSMutableAttributedString(string: "")
//                let fullnameRange = text.range(of: fullname!)
                let boldFont = UIFont.boldSystemFont(ofSize: 17)
                let boldFullname = NSMutableAttributedString(string: fullname!, attributes: [NSFontAttributeName: boldFont])
                attrText.append(boldFullname)
                attrText.append(NSMutableAttributedString(string: text))

                let boldPrice = NSMutableAttributedString(string: "$\(price)", attributes: [NSFontAttributeName: boldFont])
                attrText.append(boldPrice)
                attrText.append(NSMutableAttributedString(string: "."))
                
                cell.textLabel?.attributedText = attrText
                
//                let responseTime = response.responseTime!
//                let responseTimeNum =  Double(responseTime)
//                let date = NSDate(timeIntervalSinceReferenceDate: responseTimeNum!)
//                cell.detailTextLabel?.text = "Type: \(priceType) $\(price) Date: \(date)"
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
//            for index in 0..<getResponses((indexPath as NSIndexPath).section).count {
//                let newIndexPath = IndexPath(row: index + 1, section: (indexPath as NSIndexPath).section)
//                let cell = self.tableView.cellForRow(at: newIndexPath)
//                if let hidden = cell?.isHidden {
//                    cell?.isHidden = !hidden
//                    histories[(indexPath as NSIndexPath).section].hidden = !hidden
//                }
//            }
//            tableView.beginUpdates()
//            tableView.endUpdates()
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                if let request = self.getRequest((indexPath as NSIndexPath).section) {
                    NBRequest.removeRequest(request, completionHandler: { error in
                        print("Request Deleted")
                    })
                }
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
        else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // ...
            }
            alertController.addAction(cancelAction)
            
            let acceptAction = UIAlertAction(title: "Accept", style: .default) { action in
                // ...
            }
            alertController.addAction(acceptAction)
            
            let declineAction = UIAlertAction(title: "Decline", style: .default) { action in
                // ...
            }
            alertController.addAction(declineAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
        
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if (indexPath as NSIndexPath).row != 0 && histories[(indexPath as NSIndexPath).section].hidden {
//            return 0
//        }
//        else {
//            return 44
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        if (indexPath as NSIndexPath).row == 0 {
//            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
//                print("edit button tapped")
//            }
//            edit.backgroundColor = UIColor.lightGray
//        
//            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
//                print("delete button tapped")
//            }
//            delete.backgroundColor = UIColor.red
//        
//            return [delete, edit]
//        }
//        else {
//            let accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
//                print("accept button tapped")
//            }
//            accept.backgroundColor = UIColor.blue
//        
//            let decline = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
//                print("decline button tapped")
//            }
//            decline.backgroundColor = UIColor.red
//        
//            return [decline, accept]
//        }
//    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
//            let req = requests[indexPath.row]
//            NBRequest.removeRequest(req, completionHandler: { error in
//                guard error == nil else {
//                    print(error)
//                    return
//                }
//                
//                self.requests.removeAtIndex(indexPath.row)
//                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            })
            
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func loadHistories() {
        NBHistory.fetchSelfHistories { result in
            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            
            guard result.error == nil else {
                print(result.error)
                return
            }
            
            guard let fetchedHistories = result.value else {
                print("no histories fetched")
                return
            }
            self.histories = fetchedHistories
            
            self.tableView.reloadData()
        }
    }
    
    func refresh(_ sender: AnyObject) {
//        nextPageURLString = nil // so it doesn't try to append the results
        NearbyAPIManager.sharedInstance.clearCache()
        loadHistories()
    }

    func isMyPost(_ section: Int) -> Bool {
        return section < 3
    }
    
    func getRequest(_ section: Int) -> NBRequest? {
        return histories[section].request
    }
    
    func getResponses(_ section: Int) -> [NBResponse] {
        return histories[section].responses
    }
    
    func getResponse(_ indexPath: IndexPath) -> NBResponse? {
        return histories[(indexPath as NSIndexPath).section].responses[(indexPath as NSIndexPath).row - 1]
    }
    
    @IBAction func saveUnwind(_ segue: UIStoryboardSegue) {
        
        /*
        let newRequestVC = segue.source as! NewRequestTableViewController
        let itemName = newRequestVC.itemName
        let desc = newRequestVC.desc
        print("\(itemName) \(desc)")
        print(newRequestVC.rent)
        print(newRequestVC.selectedCategory)
        print("printend")
        
        let req = NBRequest(test: true)
        req.itemName = itemName
        req.desc = desc
        let currentLocation = LocationManager.sharedInstance.location
        req.latitude = currentLocation?.coordinate.latitude
        req.longitude = currentLocation?.coordinate.longitude
        
        req.category = newRequestVC.selectedCategory
        req.rental = newRequestVC.rent
        
        let jsonObj = JSON(req.toJSON())
        print(jsonObj)
        Alamofire.request(RequestsRouter.createRequest(req.toJSON())).response { response in
            print(response.request)
            print(response.response)
            
            //probably should not be doing this, but I need an easy way to update it for now
            self.loadHistories()
        }
 */
    }
    
    @IBAction func cancelUnwind(_ segue: UIStoryboardSegue) {
        print("cancelled new request")
    }
    
}

extension HistoryTableViewController: NewRequestTableViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushNewRequestTableViewController" {
            let newRequestVC = segue.destination.childViewControllers[0] as! NewRequestTableViewController
            newRequestVC.delegate = self
        }
    }
    
    func saved(_ request: NBRequest) {
        print(request.toJSON())

        Alamofire.request(RequestsRouter.createRequest(request.toJSON())).response { response in
            print(response.request)
            print(response.response)
            
            //probably should not be doing this, but I need an easy way to update it for now
            self.loadHistories()
        }
    }
    
    func cancelled() {
        print("yo")
//        self.navigationController?.popViewController(animated: true)
    }
    
}
