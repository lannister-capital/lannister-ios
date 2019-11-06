//
//  HoldingsRepositoryImpl.swift
//  Lannister
//
//  Created by Andre Sousa on 18/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

class HoldingsRepositoryImpl: HoldingsRepository {

    func updateHoldingsWithComputedProperties(holdings: [Holding]) -> [Holding] {
        
        var newHoldings : [Holding] = []
        for holding in holdings {
            let updatedHolding = updateHoldingWithComputedProperties(holding: holding)
            newHoldings.append(updatedHolding)
        }
        
        return newHoldings
    }
    
    func updateHoldingWithComputedProperties(holding: Holding) -> Holding {
        
        var updatedHolding = holding
        if holding.address != nil {
            // get tokens (only eth for now)
            let predicateAddress = NSPredicate(format: "address == %@", holding.address!)
            let predicateCode = NSPredicate(format: "code == %@", "ETH")
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateAddress, predicateCode])
            
            var tokenManagedObjects = TokenManagedObject.mr_findAll(with: compoundPredicate, in: NSManagedObjectContext.mr_default()) as! [TokenManagedObject]
            if tokenManagedObjects.count == 0 {
                let tokenManagedObject = TokenManagedObject(context: NSManagedObjectContext.mr_default())
                tokenManagedObject.address = holding.address
                tokenManagedObject.code = "ETH"
                let currencyManagedObject = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: "ETH", in: NSManagedObjectContext.mr_default())
                tokenManagedObject.currency = currencyManagedObject
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                tokenManagedObjects = TokenManagedObject.mr_findAll(with: compoundPredicate, in: NSManagedObjectContext.mr_default()) as! [TokenManagedObject]
            }
            let tokens = TokenDto().tokens(from: tokenManagedObjects)
            updatedHolding.representiveValue = tokens[0].value
            updatedHolding.representiveCurrency = tokens[0].currency
            for token in tokens {
                updatedHolding.totalEuroValue = Currencies.getEuroValue(value: token.value, currency: token.currency)
            }
        } else {
            updatedHolding.representiveValue = holding.value!
            updatedHolding.representiveCurrency = holding.currency!
            updatedHolding.totalEuroValue = Currencies.getEuroValue(value: holding.value!, currency: holding.currency!)
        }
        return updatedHolding
    }
}
