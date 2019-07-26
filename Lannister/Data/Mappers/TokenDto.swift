//
//  TokenDto.swift
//  Lannister
//
//  Created by Andre Sousa on 15/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class TokenDto: NSObject {

    func token(from managedObject: TokenManagedObject) -> Token {
        
        var token = Token(with: nil)
        token.address = managedObject.address
        if managedObject.name != nil {
            token.name = managedObject.name
        }
        if managedObject.code != nil {
            token.code = managedObject.code
        }
        token.value = managedObject.value
        let currencyManagedObject = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: managedObject.currency_code!)
        token.currency = CurrencyDto().currency(from: currencyManagedObject!)
        if managedObject.transactions != nil {
            if (managedObject.transactions?.allObjects.count)! > 0 {
                let transactionsManagedObjects = managedObject.transactions?.allObjects as! [TransactionManagedObject]
                let transactions = TransactionDto().transactions(from: transactionsManagedObjects)
                token.transactions = transactions
            }
        }
        return token
    }
    
    func tokens(from managedObjects: [TokenManagedObject]) -> [Token] {
        
        var tokens = Array<Token>()
        for managedObject in managedObjects {
            tokens.append(token(from: managedObject))
        }
        return tokens
    }

}
