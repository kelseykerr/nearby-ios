//
//  HistoryStateManager.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/19/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import Foundation


class HistoryStateManager {
    
    static let sharedInstance = HistoryStateManager()
    
    private var buyerBuyerConfirmStrategy: HistoryStateStrategy
    private var buyerSellerConfirmStrategy: HistoryStateStrategy
    private var buyerExchangeStrategy: HistoryStateStrategy
    private var buyerReturnStrategy: HistoryStateStrategy
    private var buyerFinishStrategy: HistoryStateStrategy

    private var sellerBuyerConfirmStrategy: HistoryStateStrategy
    private var sellerSellerConfirmStrategy: HistoryStateStrategy
    private var sellerExchangeStrategy: HistoryStateStrategy
    private var sellerReturnStrategy: HistoryStateStrategy
    private var sellerFinishStrategy: HistoryStateStrategy
    
    private init() {
        self.buyerBuyerConfirmStrategy = BuyerBuyerConfirmStrategy()
        self.buyerSellerConfirmStrategy = BuyerSellerConfirmStrategy()
        self.buyerExchangeStrategy = BuyerExchangeStrategy()
        self.buyerReturnStrategy = BuyerReturnStrategy()
        self.buyerFinishStrategy = BuyerFinishStrategy()
        
        self.sellerBuyerConfirmStrategy = SellerBuyerConfirmStrategy()
        self.sellerSellerConfirmStrategy = SellerSellerConfirmStrategy()
        self.sellerExchangeStrategy = SellerExchangeStrategy()
        self.sellerReturnStrategy = SellerReturnStrategy()
        self.sellerFinishStrategy = SellerFinishStrategy()
    }
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        switch history.status {
            case .buyer_buyerConfirm:
                return buyerBuyerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_sellerConfirm:
                return buyerSellerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_exchange:
                return buyerExchangeStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_returns:
                return buyerReturnStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_finish:
                return buyerFinishStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_buyerConfirm:
                return sellerBuyerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_sellerConfirm:
                return sellerSellerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_exchange:
                return sellerExchangeStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_returns:
                return sellerReturnStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_finish:
                return sellerFinishStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        switch history.status {
            case .buyer_buyerConfirm:
                return buyerBuyerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_sellerConfirm:
                return buyerSellerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_exchange:
                return buyerExchangeStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_returns:
                return buyerReturnStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_finish:
                return buyerFinishStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_buyerConfirm:
                return sellerBuyerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_sellerConfirm:
                return sellerSellerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_exchange:
                return sellerExchangeStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_returns:
                return sellerReturnStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_finish:
                return sellerFinishStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        switch history.status {
            case .buyer_buyerConfirm:
                return buyerBuyerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_sellerConfirm:
                return buyerSellerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_exchange:
                return buyerExchangeStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_returns:
                return buyerReturnStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .buyer_finish:
                return buyerFinishStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_buyerConfirm:
                return sellerBuyerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_sellerConfirm:
                return sellerSellerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_exchange:
                return sellerExchangeStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_returns:
                return sellerReturnStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
            case .seller_finish:
                return sellerFinishStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
    
}
