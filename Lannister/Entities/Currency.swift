//
//  Currency.swift
//  Lannister
//
//  Created by André Sousa on 08/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

struct Currency {

    var name        : String!
    var symbol      : String!
    var euroRate    : Double!
    var holdings    : [Holding]!

    init(with dictionary: [String : Any]?) {
        
    }
}
