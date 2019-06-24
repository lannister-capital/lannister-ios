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
            var holdingValue = holding.value
            if holding.value < 0 {
                holdingValue = 0
            }
            euroTotalValue += Currencies.getEuroValue(value: holdingValue!, currency: holding.currency)
        }
        
        return euroTotalValue
    }
}
