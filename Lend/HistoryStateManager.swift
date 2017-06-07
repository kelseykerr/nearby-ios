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
    private var buyerPriceConfirmStrategy: HistoryStateStrategy
    private var buyerFinishStrategy: HistoryStateStrategy
    private var buyerClosedStrategy: HistoryStateStrategy

    private var sellerBuyerConfirmStrategy: HistoryStateStrategy
    private var sellerSellerConfirmStrategy: HistoryStateStrategy
    private var sellerExchangeStrategy: HistoryStateStrategy
    private var sellerReturnStrategy: HistoryStateStrategy
    private var sellerPriceConfirmStrategy: HistoryStateStrategy
    private var sellerFinishStrategy: HistoryStateStrategy
    private var sellerClosedStrategy: HistoryStateStrategy
    
    private init() {
        self.buyerBuyerConfirmStrategy = BuyerBuyerConfirmStrategy()
        self.buyerSellerConfirmStrategy = BuyerSellerConfirmStrategy()
        self.buyerExchangeStrategy = BuyerExchangeStrategy()
        self.buyerReturnStrategy = BuyerReturnStrategy()
        self.buyerPriceConfirmStrategy = BuyerPriceConfirmStrategy()
        self.buyerFinishStrategy = BuyerFinishStrategy()
        self.buyerClosedStrategy = BuyerClosedStrategy()
        
        self.sellerBuyerConfirmStrategy = SellerBuyerConfirmStrategy()
        self.sellerSellerConfirmStrategy = SellerSellerConfirmStrategy()
        self.sellerExchangeStrategy = SellerExchangeStrategy()
        self.sellerReturnStrategy = SellerReturnStrategy()
        self.sellerPriceConfirmStrategy = SellerPriceConfirmStrategy()
        self.sellerFinishStrategy = SellerFinishStrategy()
        self.sellerClosedStrategy = SellerClosedStrategy()
    }
    
    func cell(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UITableViewCell {
        switch history.status {
        case .buyer_buyerConfirm:
            return buyerBuyerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_sellerConfirm:
            return buyerSellerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_exchange, .buyer_overrideExchange:
            return buyerExchangeStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_returns, .buyer_overrideReturn:
            return buyerReturnStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_priceConfirm:
            return buyerPriceConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_finish:
            return buyerFinishStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_closed:
            return buyerClosedStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_buyerConfirm:
            return sellerBuyerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_sellerConfirm:
            return sellerSellerConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_exchange, .seller_overrideExchange:
            return sellerExchangeStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_returns, .seller_overrideReturn:
            return sellerReturnStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_priceConfirm:
            return sellerPriceConfirmStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_finish:
            return sellerFinishStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_closed:
            return sellerClosedStrategy.cell(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
    
    func alertController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIAlertController {
        switch history.status {
        case .buyer_buyerConfirm:
            return buyerBuyerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_sellerConfirm:
            return buyerSellerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_exchange, .buyer_overrideExchange:
            return buyerExchangeStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_returns, .buyer_overrideReturn:
            return buyerReturnStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_priceConfirm:
            return buyerPriceConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_finish:
            return buyerFinishStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_closed:
            return buyerClosedStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_buyerConfirm:
            return sellerBuyerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_sellerConfirm:
            return sellerSellerConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_exchange, .seller_overrideExchange:
            return sellerExchangeStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_returns, .seller_overrideReturn:
            return sellerReturnStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_priceConfirm:
            return sellerPriceConfirmStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_finish:
            return sellerFinishStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_closed:
            return sellerClosedStrategy.alertController(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
    
    func detailViewController(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> UIViewController {
        switch history.status {
        case .buyer_buyerConfirm:
            return buyerBuyerConfirmStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_sellerConfirm:
            return buyerSellerConfirmStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_exchange, .buyer_overrideExchange:
            return buyerExchangeStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_returns, .buyer_overrideReturn:
            return buyerReturnStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_priceConfirm:
            return buyerPriceConfirmStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_finish:
            return buyerFinishStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_closed:
            return buyerClosedStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_buyerConfirm:
            return sellerBuyerConfirmStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_sellerConfirm:
            return sellerSellerConfirmStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_exchange, .seller_overrideExchange:
            return sellerExchangeStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_returns, .seller_overrideReturn:
            return sellerReturnStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_priceConfirm:
            return sellerPriceConfirmStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_finish:
            return sellerFinishStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_closed:
            return sellerClosedStrategy.detailViewController(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
    
    func rowAction(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> [UITableViewRowAction]? {
        switch history.status {
        case .buyer_buyerConfirm:
            return buyerBuyerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_sellerConfirm:
            return buyerSellerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_exchange, .buyer_overrideExchange:
            return buyerExchangeStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_returns, .buyer_overrideReturn:
            return buyerReturnStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_priceConfirm:
            return buyerPriceConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_finish:
            return buyerFinishStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_closed:
            return buyerClosedStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_buyerConfirm:
            return sellerBuyerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_sellerConfirm:
            return sellerSellerConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_exchange, .seller_overrideExchange:
            return sellerExchangeStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_returns, .seller_overrideReturn:
            return sellerReturnStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_priceConfirm:
            return sellerPriceConfirmStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_finish:
            return sellerFinishStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_closed:
            return sellerClosedStrategy.rowAction(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
    
    func canEditRowAt(historyVC: HistoryTableViewController, indexPath: IndexPath, history: NBHistory) -> Bool {
        switch history.status {
        case .buyer_buyerConfirm:
            return buyerBuyerConfirmStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_sellerConfirm:
            return buyerSellerConfirmStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_exchange, .buyer_overrideExchange:
            return buyerExchangeStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_returns, .buyer_overrideReturn:
            return buyerReturnStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_priceConfirm:
            return buyerPriceConfirmStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_finish:
            return buyerFinishStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .buyer_closed:
            return buyerClosedStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_buyerConfirm:
            return sellerBuyerConfirmStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_sellerConfirm:
            return sellerSellerConfirmStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_exchange, .seller_overrideExchange:
            return sellerExchangeStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_returns, .seller_overrideReturn:
            return sellerReturnStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_priceConfirm:
            return sellerPriceConfirmStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_finish:
            return sellerFinishStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        case .seller_closed:
            return sellerClosedStrategy.canEditRowAt(historyVC: historyVC, indexPath: indexPath, history: history)
        }
    }
}
