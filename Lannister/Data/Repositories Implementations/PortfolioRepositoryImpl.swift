//
//  PortfolioRepositoryImpl.swift
//  Lannister
//
//  Created by André Sousa on 24/06/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import Foundation
import MagicalRecord
import CoreData

class PortfolioRepositoryImpl: PortfolioRepository {

    func getEuroTotalValue() -> Double {
        
        let holdingsManagedObjects = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default())
        let holdings = HoldingDto().holdings(from: holdingsManagedObjects as! [HoldingManagedObject])

        var euroTotalValue : Double = 0
        for holding in holdings {
            if holding.address != nil {
                let tokenManagedObjects = TokenManagedObject.mr_find(byAttribute: "address", withValue: holding.address!, in: NSManagedObjectContext.mr_default()) as! [TokenManagedObject]
                let tokens = TokenDto().tokens(from: tokenManagedObjects)
                for token in tokens {
                    var tokenValue : Double = token.value
                    if tokenValue < 0 {
                        tokenValue = 0
                    }
                    euroTotalValue += Currencies.getEuroValue(value: tokenValue, currency: token.currency!)
                }
            } else {
                var holdingValue : Double? = holding.value
                if holdingValue! < 0 {
                    holdingValue = 0
                }
                euroTotalValue += Currencies.getEuroValue(value: holdingValue!, currency: holding.currency!)
            }
        }
        
        return euroTotalValue
    }
}
