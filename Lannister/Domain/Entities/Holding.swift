//
//  Holding.swift
//  Lannister
//
//  Created by André Sousa on 05/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

struct Holding {

    // attributes
    var address         : String?
    var hexColor        : String!
    var name            : String!
    var value           : Double?
    
    // relationships
    var currency        : Currency?
    var transactions    : [Transaction]?
    
    init(with dictionary: [String : Any]?) {

    }
}
