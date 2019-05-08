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
        holding.name = managedObject.name
        holding.value = managedObject.value
        holding.hexColor = managedObject.hex_color
        holding.currency = CurrencyDto().currency(from: managedObject.currency!)
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
