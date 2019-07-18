//
//  Token.swift
//  Lannister
//
//  Created by Andre Sousa on 15/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

struct Token {
    
    // attributes
    var address         : String!
    var name            : String?
    var code            : String?
    var value           : Double!
    
    var currency        : Currency!
    var transactions    : [Transaction]?

    // relationships
    init(with dictionary: [String : Any]?) {
        
    }
}
