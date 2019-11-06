//
//  HoldingUseCase.swift
//  Lannister
//
//  Created by Andre Sousa on 18/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class HoldingsUseCase: NSObject {

    var repository: Repository?
    
    convenience init(with repository: Repository) {
        self.init()
        self.repository = repository
    }
    
    func updateHoldingsWithComputedProperties(holdings: [Holding]) -> [Holding] {
        
        let repo = self.repository as! HoldingsRepository
        return repo.updateHoldingsWithComputedProperties(holdings: holdings)
    }
    
    func updateHoldingWithComputedProperties(holding: Holding) -> Holding {
        
        let repo = self.repository as! HoldingsRepository
        return repo.updateHoldingWithComputedProperties(holding: holding)
    }
}
