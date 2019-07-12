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

class WalletRepositoryImpl: WalletRepository {
    
    func getBalance(address: String, success: @escaping(Double) -> Void, failure: @escaping(_ error: Error) -> Void) {
        
    }
    
    func getTransactions(address: String, success: @escaping(_ transactions: Array<Any>) -> Void, failure: @escaping(_ error: Error) -> Void) {
        
    }

}
