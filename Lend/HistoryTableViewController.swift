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
    var cleared = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDataManager.sharedInstace.addClearable(self)
        
        self.tableView.contentInset = UIEdgeInsetsMake(-26, 0, 0, 0)
        
        //may not need this?
        if cleared {
            loadHistories()
            cleared = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()

            let bounds =  CGRect(x: (refreshControl?.bounds.origin.x)!, y: -26.0, width: (refreshControl?.bounds.size.width)!, height: (refreshControl?.bounds.size.height)!)
            self.refreshControl?.bounds = bounds
            
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        }
        
        if cleared {
            loadHistories()
            cleared = false
        }
        
        super.viewWillAppear(animated)
    }
    
//    override func viewDidUnload() {
//        UserDataManager.sharedInstace.removeClearable(self)
//    }
    
    override func clear() {
        print("History View Cleared")
        histories = []
        self.tableView.reloadData()
        cleared = true
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
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // move to strategy
        let history = histories[indexPath.section]
        if indexPath.row == 0 {
            if (history.transaction != nil && history.transaction?.id != nil && history.request?.status?.rawValue == "TRANSACTION_PENDING" && !(history.transaction?.canceled)!) {
                var shouldBeBig = false
                let response = history.getResponseById(id: (history.transaction?.responseId)!)
                if (history.transaction?.exchanged)! {
                    shouldBeBig = response?.returnTime != nil && response?.returnLocation != nil
                } else {
                    shouldBeBig = response?.exchangeLocation != nil && response?.exchangeTime != nil
                }
                return shouldBeBig ? 100 : 80
            } else {
                return 80
            }
        }
        else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = histories[indexPath.section]

        let detailViewController = HistoryStateManager.sharedInstance.detailViewController(historyVC: self, indexPath: indexPath, history: history)

        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let history = histories[indexPath.section]
        
        let rowActions = HistoryStateManager.sharedInstance.rowAction(historyVC: self, indexPath: indexPath, history: history)

        return rowActions
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let history = histories[indexPath.section]
        
        let canEditRow = HistoryStateManager.sharedInstance.canEditRowAt(historyVC: self, indexPath: indexPath, history: history)
        
        return canEditRow
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
            
            if fetchedHistories.count == 0 {
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                noDataLabel.text = "no history to show"
                noDataLabel.textColor = UIColor.black
                noDataLabel.textAlignment = .center
                self.tableView.backgroundView = noDataLabel
                self.tableView.separatorStyle = .none
            }
            
            //this may not be the best way, but will prevent from crashing
            if !UserManager.sharedInstance.userAvailable() {
                UserManager.sharedInstance.fetchUser(completionHandler: { user in
                    self.tableView.reloadData()
                })
            }
            else {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func refresh(_ sender: AnyObject) {
//        nextPageURLString = nil // so it doesn't try to append the results
        NearbyAPIManager.sharedInstance.clearCache()
        loadHistories()
    }

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

extension HistoryTableViewController: RequestDetailTableViewDelegate, ResponseDetailTableViewDelegate, TransactionDetailTableViewDelegate, EditRequestTableViewDelegate, ConfirmPriceTableViewDelegate {
    
    //request
    
    func edited(_ request: NBRequest?) {
        print("HistoryTableViewController->edited")
        requestEdited(request)
    }
    
    func closed(_ request: NBRequest?) {
        print("HistoryTableViewController->closed")
        request?.expireDate = 0
        requestEdited(request)
    }
    
    func requestEdited(_ request: NBRequest?) {
        print("HomeViewController->requestEdited")
        if let request = request {
            NBRequest.editRequest(request) { error in
                print("Request edited")
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.loadHistories()
            }
        }
    }
    
    //response
    
    func edited(_ response: NBResponse?) {
        print("HistoryTableViewController->edited")
        responseEdited(response)
    }

    // do we need this here???
    func offered(_ request: NBResponse?) {
        print("HistoryTableViewController->offered")
    }
    
    func withdrawn(_ response: NBResponse?) {
        print("HistoryTableViewController->withdrawn")
        response?.sellerStatus = .withdrawn
        responseEdited(response)
    }
    
    func accepted(_ response: NBResponse?) {
        print("HistoryTableViewController->accepted")
        response?.buyerStatus = .accepted
        responseEdited(response)
    }
    
    func declined(_ response: NBResponse?) {
        print("HistoryTableViewController->declined")
        response?.buyerStatus = .declined
        responseEdited(response)
    }
    
    func responseEdited(_ response: NBResponse?) {
        print("HomeViewController->responseEdited")
        if let response = response {
            NBResponse.editResponse(response) { error in
                print("Response edited")
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.loadHistories()
            }
        }
    }
 
    //transaction
    //some are below
    func confirmed(_ transaction: NBTransaction?) {
        if let transaction = transaction {
            NBTransaction.verifyTransactionPrice(id: transaction.id!, transaction: transaction) { error in
                print("price verified test")
                if let error = error {
                    let alert = Utils.createServerErrorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
                self.loadHistories()
            }
        }
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

