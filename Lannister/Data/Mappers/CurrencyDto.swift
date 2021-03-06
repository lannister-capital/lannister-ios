//
//  CurrencyDto.swift
//  Lannister
//
//  Created by André Sousa on 08/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class CurrencyDto: NSObject {

    func currency(from managedObject: CurrencyManagedObject) -> Currency {
        
        var currency = Currency(with: nil)
        currency.code = managedObject.code
        currency.name = managedObject.name
        currency.euroRate = managedObject.euro_rate
        currency.symbol = managedObject.symbol
        return currency
    }
    
    func currencies(from managedObjects: [CurrencyManagedObject]) -> [Currency] {
        
        var currencies = Array<Currency>()
        for managedObject in managedObjects {
            currencies.append(currency(from: managedObject))
        }
        return currencies
    }

}
