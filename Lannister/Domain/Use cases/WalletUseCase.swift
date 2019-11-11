//
//  WalletUseCase.swift
//  Lannister
//
//  Created by Andre Sousa on 12/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import Foundation

class WalletUseCase : NSObject {
    
    var repository: Repository?
    
    convenience init(with repository: Repository) {
        self.init()
        self.repository = repository
    }
    
    func getBalance(address: String, success: @escaping(Double) -> Void, failure: @escaping(_ error: Error) -> Void) {
        
        let repo = self.repository as! WalletRepository
        return repo.getBalance(address: address, success: success, failure: failure)
    }
    
    func getBalanceOfToken(address: String, erc20TokenAddress: String, success: @escaping(Double) -> Void, failure: @escaping(_ error: Error) -> Void) {
        let repo = self.repository as! WalletRepository
        return repo.getBalanceOfToken(address: address, erc20TokenAddress: erc20TokenAddress, success: success, failure: failure)
    }
    
    func getTransactions(address: String, success: @escaping(_ transactions: Array<Transaction>?) -> Void, failure: @escaping(_ error: Error) -> Void) {

        let repo = self.repository as! WalletRepository
        return repo.getTransactions(address: address, success: success, failure: failure)
    }

}
