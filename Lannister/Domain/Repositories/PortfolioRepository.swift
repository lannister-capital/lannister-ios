//
//  PortfolioRepository.swift
//  Lannister
//
//  Created by André Sousa on 24/06/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

protocol PortfolioRepository : Repository {

    func getEuroTotalValue() -> Double
}
