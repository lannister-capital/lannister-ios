//
//  CurrencyUserDefaults.swift
//  Lannister
//
//  Created by André Sousa on 10/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class CurrencyUserDefaults: NSObject {

    func setDefaultCurrency(name: String) {
        UserDefaults.standard.set(name, forKey: "defaultCurrency")
        UserDefaults.standard.synchronize()
    }
    
    func getDefaultCurrencyName() -> String? {
        if let currency = UserDefaults.standard.value(forKey: "defaultCurrency") as? String {
            return currency
        }
        return nil
    }

}
