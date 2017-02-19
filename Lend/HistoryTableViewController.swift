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
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        }
        
        super.viewWillAppear(animated)
    }
    
    // MARK - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return histories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if histories[section].status == .buyerConfirm {
            return histories[section].responses.count + 1
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
        
        //switch statement
        let history = histories[indexPath.section]
        switch history.status {
            case .buyerConfirm:
                if (indexPath as NSIndexPath).row == 0 {
//                    cell.textLabel?.text = "request cell"
                    if history.isMyRequest() {
                        let item = (history.request?.itemName)!
                        cell.textLabel?.text = "You want to borrow \(item)."
                    }
                    else {
                        let name: String = (history.request?.user?.firstName!)!
                        let item = (history.request?.itemName)!
                        cell.textLabel?.text = "\(name) wants to borrow \(item)."
                    }
                }
                else {
//                    cell.textLabel?.text = "response cell"
                    if history.isMyRequest() {
                        let response = getResponse(indexPath)
                        let name: String = (response?.seller?.firstName)!
                        let price = (response?.offerPrice)!
                        cell.textLabel?.text = "\(name) is offering to sell it to you for $\(price)."
                    }
                    else {
                        let response = getResponse(indexPath)
                        let name: String = (history.request?.user?.firstName!)!
                        let price = (response?.offerPrice)!
                        cell.textLabel?.text = "You are offering to sell it to \(name) for $\(price)."
                    }
                }
            case .sellerConfirm:
                // BUYER: Awaiting NAME to confirm offer for ITEM.
                // SELLER: NAME has accepted your offer for ITEM.
                cell.textLabel?.text = "seller comfirm cell"
                if history.isMyRequest() {
//                    let name = (response?.seller?.firstName)!
                    let name = "<NAME>"
                    let item = (history.request?.itemName)!
                    cell.textLabel?.text = "Awaiting \(name) to confirm offer for \(item)."
                }
                else {
                    let name = history.request?.user?.firstName!
                    let item = (history.request?.itemName)!
                    cell.textLabel?.text = "\(name) has accepted your offer for \(item). Please confirm to proceed."
                }
            case .exchange:
                // You are meeting NAME to exchange ITEM.
//                cell.textLabel?.text = "exchange cell"
                if history.isMyRequest() {
//                    let name = (response?.seller?.firstName)!
                    let name = "<NAME>"
                    let item = (history.request?.itemName)!
                    cell.textLabel?.text = "You are meeting \(name) to exchange \(item)."
                }
                else {
                    let name: String = (history.request?.user?.firstName!)!
                    let item = (history.request?.itemName)!
                    cell.textLabel?.text = "You are meeting \(name) to exchange \(item)."
                }
            case .returns:
                // You are meeting NAME to return ITEM.
                if history.isMyRequest() {
                    let name = "<NAME>"
                    let item = (history.request?.itemName)!
                    cell.textLabel?.text = "You are meeting \(name) to return \(item)."
                }
                else {
                    let name: String = (history.request?.user?.firstName!)!
                    let item = (history.request?.itemName)!
                    cell.textLabel?.text = "You are meeting \(name) to claim \(item)."
                }
            case .finish:
                // You have successful completed transaction for ITEM.
                let item = (history.request?.itemName)!
                cell.textLabel?.text = "You have successfully completed transaction for \(item)."
        }
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = histories[indexPath.section]

        let alertController = getAlertController(status: history.status, myRequest: history.isMyRequest(), indexPath: indexPath)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
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

extension HistoryTableViewController {
    
    func getBuyerConfirmRequestAlertControllerForBuyer(indexPath: IndexPath) -> UIAlertController {
        let alertController = UIAlertController(title: "BuyerConfirmRequest Buyer", message: nil, preferredStyle: .actionSheet)
        
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
        
        return alertController
    }
    
    func getBuyerConfirmOfferAlertControllerForBuyer(indexPath: IndexPath) -> UIAlertController {
        let alertController = UIAlertController(title: "BuyerConfirmOffer Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { action in
            print("accepted:")
            if let response = self.getResponse(indexPath) {
                print("got an response")
                
                response.buyerStatus = BuyerStatus(rawValue: "ACCEPTED")
//                response.sellerStatus = SellerStatus(rawValue: "ACCEPTED")
                
//                    response.responseStatus = "ACCEPTED"
                
                NBResponse.editResponse(response, completionHandler: { error in
                    print("done")
                })
            }
        }
        alertController.addAction(acceptAction)
        
        let declineAction = UIAlertAction(title: "Decline", style: .default) { action in
            // ...
        }
        alertController.addAction(declineAction)
        
        return alertController
    }
    
    func getBuyerConfirmAlertControllerForSeller() -> UIAlertController {
        let alertController = UIAlertController(title: "BuyerConfirm Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func getSellerConfirmAlertControllerForBuyer() -> UIAlertController {
        let alertController = UIAlertController(title: "SellerConfirm Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func getSellerConfirmAlertControllerForSeller(indexPath: IndexPath) -> UIAlertController {
        let alertController = UIAlertController(title: "SellerConfirm Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { action in
            print("accepted:")
            if let response = self.getResponse2(indexPath) {
                print("got an response")
                
//                response.buyerStatus = BuyerStatus(rawValue: "ACCEPTED")
                response.sellerStatus = SellerStatus(rawValue: "ACCEPTED")
                
                NBResponse.editResponse(response, completionHandler: { error in
                    print("done")
                })
            }
        }
        alertController.addAction(acceptAction)
        
        let declineAction = UIAlertAction(title: "Decline", style: .default) { action in
            // ...
        }
        alertController.addAction(declineAction)
        
        return alertController
    }
    
    func getExchangeAlertControllerForBuyer(indexPath: IndexPath) -> UIAlertController {
        let alertController = UIAlertController(title: "Exchange Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let exchangeAction = UIAlertAction(title: "Exchange", style: .default) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRScannerNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let scannerVC = (navVC.childViewControllers[0] as! QRScannerViewController)
            scannerVC.delegate = self
            scannerVC.transaction = self.getTransaction(indexPath.section)
            self.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(exchangeAction)
        
        return alertController
    }
    
    func getExchangeAlertControllerForSeller(indexPath: IndexPath) -> UIAlertController {
        let alertController = UIAlertController(title: "Exchange Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let exchangeAction = UIAlertAction(title: "Exchange", style: .default) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let navVC = storyboard.instantiateViewController(
                withIdentifier: "QRGeneratorNavigationController") as? UINavigationController else {
                    assert(false, "Misnamed view controller")
                    return
            }
            let generatorVC = (navVC.childViewControllers[0] as! QRGeneratorViewController)
            generatorVC.delegate = self
            generatorVC.transaction = self.getTransaction(indexPath.section)
            self.present(navVC, animated: true, completion: nil)
        }
        alertController.addAction(exchangeAction)
        
        return alertController
    }
    
    func getReturnsAlertControllerForBuyer() -> UIAlertController {
        let alertController = UIAlertController(title: "Returns Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func getReturnsAlertControllerForSeller() -> UIAlertController {
        let alertController = UIAlertController(title: "Returns Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }

    func getFinishAlertControllerForBuyer() -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Buyer", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func getFinishAlertControllerForSeller() -> UIAlertController {
        let alertController = UIAlertController(title: "Finish Seller", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func getAlertController(status: HistoryStatus, myRequest: Bool, indexPath: IndexPath) -> UIAlertController {
        var alertController = UIAlertController()
        switch status {
        case .buyerConfirm:
            if myRequest {
                if (indexPath as NSIndexPath).row == 0 {
                    alertController = getBuyerConfirmRequestAlertControllerForBuyer(indexPath: indexPath)
                }
                else {
                    alertController = getBuyerConfirmOfferAlertControllerForBuyer(indexPath: indexPath)
                }
            }
            else {
                alertController = getBuyerConfirmAlertControllerForSeller()
            }
        case .sellerConfirm:
            if myRequest {
                alertController = getSellerConfirmAlertControllerForBuyer()
            }
            else {
                alertController = getSellerConfirmAlertControllerForSeller(indexPath: indexPath)
            }
        case .exchange:
            if myRequest {
                alertController = getExchangeAlertControllerForBuyer(indexPath: indexPath)
            }
            else {
                alertController = getExchangeAlertControllerForSeller(indexPath: indexPath)
            }
        case .returns:
            if myRequest {
//                alertController = getReturnsAlertControllerForBuyer()
                alertController = getExchangeAlertControllerForSeller(indexPath: indexPath)
            }
            else {
//                alertController = getReturnsAlertControllerForSeller()
                alertController = getExchangeAlertControllerForBuyer(indexPath: indexPath)
            }
        case .finish:
            if myRequest {
                alertController = getFinishAlertControllerForBuyer()
            }
            else {
                alertController = getFinishAlertControllerForSeller()
            }
        }
        
        return alertController
    }
    
}
