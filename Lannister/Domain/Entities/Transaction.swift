//
//  Transaction.swift
//  Lannister
//
//  Created by André Sousa on 05/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

struct Transaction {

    var identifier  : String!
    var name        : String!
    var type        : String!
    var value       : Double!
    var holding     : Holding!
    
    init(with dictionary: [String : Any]?) {
        
    }
}
