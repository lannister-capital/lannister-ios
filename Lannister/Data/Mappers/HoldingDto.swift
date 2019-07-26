//
//  HoldingDto.swift
//  Lannister
//
//  Created by André Sousa on 05/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

class HoldingDto : NSObject {

    func holding(from managedObject: HoldingManagedObject) -> Holding {
        
        var holding = Holding(with: nil)
        if(managedObject.address != nil) {
            holding.address = managedObject.address
        }
        holding.name = managedObject.name
        holding.value = managedObject.value?.doubleValue
        holding.hexColor = managedObject.hex_color
        let currencyManagedObject = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: managedObject.currency_code!)
        holding.currency = CurrencyDto().currency(from: currencyManagedObject!)

//        if managedObject.currency != nil {
//            holding.currency = CurrencyDto().currency(from: managedObject.currency!)
//        }
        if managedObject.transactions != nil {
            if (managedObject.transactions?.allObjects.count)! > 0 {
                let transactionsManagedObjects = managedObject.transactions?.allObjects as! [TransactionManagedObject]
                let transactions = TransactionDto().transactions(from: transactionsManagedObjects)
                holding.transactions = transactions
            }
        }
        return holding
    }
    
    func holdings(from managedObjects: [HoldingManagedObject]) -> [Holding] {
        
        var holdings = Array<Holding>()
        for managedObject in managedObjects {
            holdings.append(holding(from: managedObject))
        }
        return holdings
    }

}
