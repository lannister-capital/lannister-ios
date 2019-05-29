//
//  TransactionDto.swift
//  Lannister
//
//  Created by André Sousa on 06/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

class TransactionDto : NSObject {
    
    func transaction(from managedObject: TransactionManagedObject) -> Transaction {
        
        var transaction = Transaction(with: nil)
        transaction.identifier = managedObject.id
        transaction.name = managedObject.name
        transaction.type = managedObject.type
        transaction.value = managedObject.value
        transaction.holding = HoldingDto().holding(from: managedObject.holding!)
        return transaction
    }
    
    func transactions(from managedObjects: [TransactionManagedObject]) -> [Transaction] {
        
        var transactions = Array<Transaction>()
        for managedObject in managedObjects {
            transactions.append(transaction(from: managedObject))
        }
        return transactions
    }
    
}
