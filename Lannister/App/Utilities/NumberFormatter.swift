//
//  NumberFormatter.swift
//  Lannister
//
//  Created by Andre Sousa on 09/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double? {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return nil
    }
}
