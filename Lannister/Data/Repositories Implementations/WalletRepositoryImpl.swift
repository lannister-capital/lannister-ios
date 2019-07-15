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
    
    func getTransactions(address: String, success: @escaping(_ transactions: Array<Any>) -> Void, failure: @escaping(_ error: Error) -> Void) {
        
    }

}
