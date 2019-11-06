//
//  HoldingsRepository.swift
//  Lannister
//
//  Created by Andre Sousa on 18/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

protocol HoldingsRepository: Repository {

    func updateHoldingsWithComputedProperties(holdings: [Holding]) -> [Holding]
    func updateHoldingWithComputedProperties(holding: Holding) -> Holding
}
