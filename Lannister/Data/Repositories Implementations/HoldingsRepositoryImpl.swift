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
        for var holding in holdings {
            if holding.address != nil {
                // get tokens (only eth for now)
                let predicateAddress = NSPredicate(format: "address == %@", holding.address!)
                let predicateCode = NSPredicate(format: "code == %@", "ETH")
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateAddress, predicateCode])
                
                let tokenManagedObjects = TokenManagedObject.mr_findAll(with: compoundPredicate, in: NSManagedObjectContext.mr_default()) as! [TokenManagedObject]
                let tokens = TokenDto().tokens(from: tokenManagedObjects)
                holding.representiveValue = tokens[0].value
                holding.representiveCurrency = tokens[0].currency
                for token in tokens {
                    holding.totalEuroValue = Currencies.getEuroValue(value: token.value, currency: token.currency)
                }
            } else {
                holding.representiveValue = holding.value!
                holding.representiveCurrency = holding.currency!
                holding.totalEuroValue = Currencies.getEuroValue(value: holding.value!, currency: holding.currency!)
            }
            newHoldings.append(holding)
        }
        
        return newHoldings
    }
}
