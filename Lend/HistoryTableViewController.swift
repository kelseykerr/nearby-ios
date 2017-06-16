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
import DZNEmptyDataSet
import MBProgressHUD

// changed unwind? to use protocols (delegate) instead, for consistency
class HistoryTableViewController: UITableViewController {

    var histories = [NBHistory]()
    var nextPageURLString: String?
    var isLoading = false
    var cleared = true
    
    var historyFilter = HistoryFilter()

    deinit {
        if tableView != nil {
            self.tableView.emptyDataSetSource = nil
            self.tableView.emptyDataSetDelegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDataManager.sharedInstace.addClearable(self)
        
        self.tableView.contentInset = UIEdgeInsetsMake(-26, 0, 0, 0)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        self.tableView.tableFooterView = UIView()
        
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
        //show responses when:
        //I'm the buyer AND I'm the requester (not an inventoryRequest)
        //I'm the seller AND I'm the reqeuster (and inventoryReqeust)
        let showBuyerChildren = (histories[section].status == .buyer_buyerConfirm || histories[section].status == .buyer_sellerConfirm) && histories[section].isMyRequest()
        let showSellerChildren = (histories[section].status == .seller_sellerConfirm || histories[section].status == .seller_buyerConfirm) && histories[section].isMyRequest()

        if showSellerChildren || showBuyerChildren {
            return histories[section].responses.count + 1
        } else {
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
        let history = histories[indexPath.section]
        
        let height = HistoryStateManager.sharedInstance.heightForRowAt(historyVC: self, indexPath: indexPath, history: history)
        
        return height

        /*
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
        */
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
        let filter = self.historyFilter
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "fetching"
        
        NBHistory.fetchHistories(includeTransaction: filter.includeTransaction, includeRequest: filter.includeRequest, includeOffer: filter.includeOffer, includeOpen: filter.includeOpen, includeClosed: filter.includeClosed) { (result, error) in

            if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
            
            loadingNotification.hide(animated: true)
            guard error == nil else {
                print(error)
                return
            }
            
            guard let fetchedHistories = result.value else {
                print("no histories fetched")
                return
            }
            
            self.histories = fetchedHistories

            /*
            if fetchedHistories.count == 0 {
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                noDataLabel.text = "no history to show"
                noDataLabel.textColor = UIColor.black
                noDataLabel.textAlignment = .center
                self.tableView.backgroundView = noDataLabel
                self.tableView.separatorStyle = .none
            } else {
                self.tableView.backgroundView = nil;

            }
             */
            
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

extension HistoryTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        let sizeChange = CGSize(width: 100, height: 100)
        let image = UIImage(named: "pin_grey_150")

        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image?.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "no history to show")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return CGFloat(-25)
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
        if response?.isOfferToBuyOrRent ?? false {
            response?.sellerStatus = .accepted
        } else {
            response?.buyerStatus = .accepted
        }
        responseEdited(response)
    }
    
    func declined(_ response: NBResponse?) {
        print("HistoryTableViewController->declined")
        if response?.isOfferToBuyOrRent ?? false {
            response?.sellerStatus = .withdrawn
        } else {
            response?.buyerStatus = .declined
        }
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

extension HistoryTableViewController: HistoryFilterTableViewDelegate {
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let navVC = storyboard.instantiateViewController(withIdentifier: "HistoryFilterNavigationController") as? UINavigationController else {
            assert(false, "Misnamed view controller")
            return
        }
        let filterVC = (navVC.childViewControllers[0] as! HistoryFilterTableViewController)
        filterVC.delegate = self
        filterVC.filter = self.historyFilter
        self.present(navVC, animated: true, completion: nil)
    }
    
    func filtered(filter: HistoryFilter) {
        self.historyFilter = filter
        print("filtered")
        loadHistories()
    }
    
    func filterCancelled() {
        print("filter cancelled")
    }
    
}
