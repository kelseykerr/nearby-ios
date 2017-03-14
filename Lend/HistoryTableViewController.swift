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
        
        self.tableView.contentInset = UIEdgeInsetsMake(-26, 0, 0, 0)
        
        loadHistories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()

            let bounds =  CGRect(x: (refreshControl?.bounds.origin.x)!, y: -26.0, width: (refreshControl?.bounds.size.width)!, height: (refreshControl?.bounds.size.height)!)
            self.refreshControl?.bounds = bounds
            
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        }
        
        super.viewWillAppear(animated)
    }
    
    // MARK - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return histories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if histories[section].status == .buyer_buyerConfirm {
            return histories[section].responses.count + 1
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let history = histories[indexPath.section]
        
        let cell = HistoryStateManager.sharedInstance.cell(historyVC: self, indexPath: indexPath, history: history)
        
        return cell
/*
        if (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
     
            if let transaction = histories[indexPath.section].transaction {
                print("Yay, transaction is available")
                let text = "You are meeting with * to exchange "
                let attrText = NSMutableAttributedString(string: "")
//                let boldFont = UIFont.boldSystemFont(ofSize: 17)
//                let boldFullname = NSMutableAttributedString(string: "You", attributes: [NSFontAttributeName: boldFont])
//                attrText.append(boldFullname)
                attrText.append(NSMutableAttributedString(string: text))
//                    
//                let boldItemName = NSMutableAttributedString(string: request.itemName!, attributes: [NSFontAttributeName: boldFont])
//                attrText.append(boldItemName)
//                attrText.append(NSMutableAttributedString(string: "."))
                
                cell.textLabel?.attributedText = attrText
            }
            else {
                print("Boo, transaction is not available")
                if let request = getRequest((indexPath as NSIndexPath).section) {
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
                let boldFont = UIFont.boldSystemFont(ofSize: 17)
//                let boldFullname = NSMutableAttributedString(string: fullname!, attributes: [NSFontAttributeName: boldFont])
//                attrText.append(boldFullname)
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
 */
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        }
        else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = histories[indexPath.section]

//        let alertController = HistoryStateManager.sharedInstance.alertController(historyVC: self, indexPath: indexPath, history: history)
//        
//        self.present(alertController, animated: true, completion: nil)
        let detailViewController = HistoryStateManager.sharedInstance.detailViewController(historyVC: self, indexPath: indexPath, history: history)
        
        self.navigationController?.pushViewController(detailViewController, animated: true)        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let history = histories[indexPath.section]
        
        let rowActions = HistoryStateManager.sharedInstance.rowAction(historyVC: self, indexPath: indexPath, history: history)
        return rowActions
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("blah")
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

//    func isMyPost(_ section: Int) -> Bool {
//        return section < 3
//    }
    
    func getHistory(_ section: Int) -> NBHistory? {
        return histories[section]
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
    
    func getResponse2(_ indexPath: IndexPath) -> NBResponse? {
        return histories[(indexPath as NSIndexPath).section].responses[(indexPath as NSIndexPath).row]
    }
    
    func getTransaction(_ section: Int) -> NBTransaction? {
        return histories[section].transaction
    }
    
}

extension HistoryTableViewController: NewRequestTableViewDelegate {
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let navVC = storyboard.instantiateViewController(
            withIdentifier: "NewRequestNavigationController") as? UINavigationController else {
                assert(false, "Misnamed view controller")
                return
        }
        let newRequestVC = (navVC.childViewControllers[0] as! NewRequestTableViewController)
        newRequestVC.delegate = self
        self.present(navVC, animated: true, completion: nil)
    }
    
    func saved(_ request: NBRequest) {
        print(request.toJSON())

        Alamofire.request(RequestsRouter.createRequest(request.toJSON())).response { response in
//            print(response.request)
//            print(response.response)
            
            //probably should not be doing this, but I need an easy way to update it for now
            self.loadHistories()
        }
    }
    
    func cancelled() {
//        self.navigationController?.popViewController(animated: true)
    }

}

extension HistoryTableViewController: QRGeneratorViewDelegate {
    
    func next() {
        print("QRGen, saved")
        
        self.loadHistories()
    }
    
    func generateCancelled() {
        
    }

}

extension HistoryTableViewController: QRScannerViewDelegate {
    
    func scanned(transId: String, code: String) {
        print("trans: \(transId) yay: \(code)")
        
        NBTransaction.editTransactionCode(id: transId, code: code) { error in
            print("done")
            
            self.loadHistories()
        }

    }
    
    func scanCancelled() {
    }
    
}

