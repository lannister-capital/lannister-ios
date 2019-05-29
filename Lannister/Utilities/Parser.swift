//
//  Parser.swift
//  Lannister
//
//  Created by Andre Sousa on 29/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            do {
                return try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            } catch {
                print(error)
                return nil
            }
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}
