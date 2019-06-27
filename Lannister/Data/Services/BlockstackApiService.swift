//
//  BlockstackApiService.swift
//  Lannister
//
//  Created by André Sousa on 14/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Blockstack
import MagicalRecord
import Groot

class BlockstackApiService: NSObject {

    override init() {
        super.init()
    }
    
    func send(returns: @escaping(Error?) -> Void) {
        
        let lannisterManagedObjects = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default()) as! [HoldingManagedObject]
        let lannisterData = json(fromObjects: lannisterManagedObjects)
        guard let data = try? JSONSerialization.data(withJSONObject: lannisterData, options: []) else {
            return
        }
        let jsonString = String(data: data, encoding: String.Encoding.utf8)!

        Blockstack.shared.putFile(to: "db.json", text: jsonString, encrypt: true, completion: { (file, error) in
            
            print("overwrite db json")
            returns(error)
        })
    }
    
    func sync(returns: @escaping(Error?) -> Void) {

        Blockstack.shared.getFile(at: "db.json", decrypt: true) { (response, error) in
            if let decryptedResponse = response as? DecryptedValue {
                let responseString = decryptedResponse.plainText
                if let parsedHoldings = responseString!.parseJSONString as? Array<Any> {
                    print("parsedHoldings \(String(describing: parsedHoldings))")
                    let holdings = self.parseHoldings(holdings: parsedHoldings as NSArray)
                    print("new holdings \(String(describing: holdings))")
                    NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                }
                returns(error)
            }
        }
    }
    
    internal func parseHoldings(holdings: NSArray) -> Array<HoldingManagedObject>? {
        
        var newHoldings : Array<HoldingManagedObject>? = Array<HoldingManagedObject>()
        for holding in holdings {
            let holdingJson : JSONDictionary = holding as! JSONDictionary
            do {
                let newHolding: HoldingManagedObject = try object(fromJSONDictionary: holdingJson, inContext: NSManagedObjectContext.mr_default())
                newHoldings?.append(newHolding)
            } catch let error as NSError {
                print("error parsing holdings \(error)")
            }
        }
        return newHoldings
    }

}