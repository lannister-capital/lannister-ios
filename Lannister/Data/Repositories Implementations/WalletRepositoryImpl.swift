//
//  WalletRepositoryImpl.swift
//  Lannister
//
//  Created by Andre Sousa on 12/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord
import CoreData
import web3swift

class WalletRepositoryImpl: WalletRepository {
    
    func getBalance(address: String, success: @escaping(Double) -> Void, failure: @escaping(_ error: Error) -> Void) {
        
        print("getBalance address \(address)")
        DispatchQueue.global(qos: .background).async {
            let walletAddress = EthereumAddress(address, ignoreChecksum: true)!
            let web3 = Web3.InfuraMainnetWeb3(accessToken: "c7b6351e2ba84d3e94d1b33c14bb9a16") // Mainnet Infura Endpoint Provider
            let balanceResult = try! web3.eth.getBalance(address: walletAddress)
            let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!

            print("balanceString \(balanceString)")
            success(balanceString.doubleValue!)
        }
    }
    
    func getTransactions(address: String, success: @escaping(_ transactions: Array<Transaction>?) -> Void, failure: @escaping(_ error: Error) -> Void) {
        
        let service = EtherScanApiService()

        let params = ["module": "account",
                      "action": "txlist",
                      "address": address,
                      "startblock": 0,
                      "block": 99999999,
                      "sort": "asc",
                      "apikey": service.apiKey] as [String : Any]
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        service.getTransactions(params: params) { response in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch (response!.result) {
            case .success(let JSON):
                print("got transactions: \(JSON)")
                
                if let status = (JSON as AnyObject).object(forKey: "status") as? String {
                    if status == "1" {
                        let transactionsJSON = (JSON as AnyObject).object(forKey: "result") as! NSArray
                        var transactions : [Transaction] = []
                        for transactionJSON in transactionsJSON {
                            if let transactionDic = transactionJSON as? [String: Any] {
                                var transaction = Transaction(with: transactionDic)
                                transaction.identifier = transactionDic["blockHash"] as? String
                                transaction.value = ((transactionDic["value"] as? String)?.doubleValue)! / 1000000000000000000.0
                                if (transactionDic["from"] as! String).lowercased() == address.lowercased() {
                                    transaction.type = "debit"
                                    transaction.name = transactionDic["to"] as? String
                                } else {
                                    transaction.type = "credit"
                                    transaction.name = transactionDic["from"] as? String
                                }
                                transactions.append(transaction)
                            }
                        }
                        success(transactions)
                    } else {
                        success(nil)
                    }
                } else {
                    success(nil)
                }
                
            case .failure(let error):
                print("error getAppointments - > \n    \(error.localizedDescription) \n")
                failure(error)
            }
        }
    }

}
