//
//  PortfolioUseCase.swift
//  Lannister
//
//  Created by André Sousa on 24/06/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import Foundation

class PortfolioUseCase : NSObject {
    
    var repository: Repository?
    
    convenience init(with repository: Repository) {
        self.init()
        self.repository = repository
    }
    
    func getEuroTotalValue() -> Double {
        
        let repo = self.repository as! PortfolioRepository
        return repo.getEuroTotalValue()
    }
}
