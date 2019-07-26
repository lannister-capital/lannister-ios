//
//  BaseApiService.swift
//  Lannister
//
//  Created by André Sousa on 08/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Groot

class BaseApiService: NSObject {
        
    let currencyBaseUrl = "https://api.exchangeratesapi.io"
    let currencyCryptoBaseUrl = "https://api.cryptonator.com/api/ticker"
    
    
    func setupValueTransformers() {
        
        ValueTransformer.setValueTransformer(withName: "StringToDate", transform: toDate)
    }
    
    func toDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: value)
    }

}
