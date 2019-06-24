//
//  Currencies.swift
//  Lannister
//
//  Created by André Sousa on 10/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

struct Currencies {
    
    static func getDefaultCurrencySymbol() -> String {
        
        let currencyCode = CurrencyUserDefaults().getDefaultCurrencyCode()!
        let currencyManagedObject = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: currencyCode, in: NSManagedObjectContext.mr_default())!
        let currency = CurrencyDto().currency(from: currencyManagedObject)
        
        return currency.symbol
    }
    
    static func getDefaultCurrencyEuroRate() -> Double {
        
        let currencyCode = CurrencyUserDefaults().getDefaultCurrencyCode()!
        let currencyManagedObject = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: currencyCode, in: NSManagedObjectContext.mr_default())!
        let currency = CurrencyDto().currency(from: currencyManagedObject)
        
        return currency.euroRate
    }
    
    static func getEuroValue(value: Double, currency: Currency) -> Double {
        
        return value / currency.euroRate
    }

}
