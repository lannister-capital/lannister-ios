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
        var holdings = HoldingDto().holdings(from: holdingsManagedObjects as! [HoldingManagedObject])
        holdings = HoldingsUseCase(with: HoldingsRepositoryImpl()).updateHoldingsWithComputedProperties(holdings: holdings)

        var euroTotalValue : Double = 0
        for holding in holdings {
            euroTotalValue += Currencies.getEuroValue(value: holding.representiveValue!, currency: holding.representiveCurrency!)
        }
        
        return euroTotalValue
    }
}
