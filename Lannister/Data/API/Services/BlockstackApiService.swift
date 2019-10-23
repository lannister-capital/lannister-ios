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

class BlockstackApiService: BaseApiService {
    
    let dbVersion = "1.0.4"

    override init() {
        super.init()
    }

    func send(returns: @escaping(String?) -> Void) {
        
        let holdingsManagedObjects = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default()) as! [HoldingManagedObject]
        var holdingsArray : [Any] = []
        for holding in holdingsManagedObjects {
            let holdingDic =
                ["hex_color" : holding.hex_color!,
                 "id": holding.id!,
                 "name": holding.name!,
                 "value": holding.value!.doubleValue,
                 "currency_code": holding.currency!.code!] as [String : Any]
            holdingsArray.append(holdingDic)
        }
        let versionString = dbVersion
        let lannisterDictionary = ["db_version": versionString, "holdings": holdingsArray] as [String : Any]
        guard let data = try? JSONSerialization.data(withJSONObject: lannisterDictionary, options: []) else {
            return
        }
        let jsonString = String(data: data, encoding: String.Encoding.utf8)!
        Blockstack.shared.putFile(to: "db.json", text: jsonString, encrypt: true, completion: { (file, error) in
            print("overwrite db json")
            if error != nil {
                print("error \(String(describing: error?.localizedDescription))")
                returns(error?.localizedDescription)
            } else {
                returns(nil)
            }
        })
    }
    
    func sync(returns: @escaping(String?) -> Void) {

        Blockstack.shared.getFile(at: "db.json", decrypt: true) { (response, error) in
            if let decryptedResponse = response as? DecryptedValue {
                let responseString = decryptedResponse.plainText
                let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                if let parsedResponse = responseString!.parseJSONString as? [String: Any] {
                    if let version = parsedResponse["db_version"] as? String {
                        if version != versionString {
                            let errorMessage = "You're using on old version of the app. Please update the app on the App Store to be able to sync your holdings."
                            returns(errorMessage)
                        } else {
                            if let parsedHoldings = parsedResponse["holdings"] as? Array<Any> {
                                let localHoldings = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default()) as! [HoldingManagedObject]
                                for holding in localHoldings {
                                    holding.mr_deleteEntity(in: NSManagedObjectContext.mr_default())
                                }
                                _ = self.parseHoldings(holdings: parsedHoldings as NSArray)
                                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                                returns(nil)
                            }
                        }
                    }
                }
                print("error \(String(describing: error?.localizedDescription))")
                returns(error?.localizedDescription)
            }
            if error != nil {
                print("error \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func checkUserData(returns: @escaping(Bool) -> Void) {
        
        Blockstack.shared.getFile(at: "db.json", decrypt: true) { (response, error) in
            if (response as? DecryptedValue) != nil {
                returns(true)
            } else {
                returns(false)
            }
        }
    }
    
    internal func parseHoldings(holdings: NSArray) -> Array<HoldingManagedObject>? {
        
        var newHoldings : Array<HoldingManagedObject>? = Array<HoldingManagedObject>()
        for holding in holdings {
            let holdingJson : JSONDictionary = holding as! JSONDictionary
            var newHolding = HoldingManagedObject.mr_findFirst(byAttribute: "id", withValue: holdingJson["id"]!, in: NSManagedObjectContext.mr_default())
            if newHolding == nil {
                newHolding = HoldingManagedObject(context: NSManagedObjectContext.mr_default())
            }
            if let address = holdingJson["address"] as? String {
               newHolding!.address = address
            }
            newHolding!.id = holdingJson["id"] as? String
            newHolding!.hex_color = holdingJson["hex_color"] as? String
            newHolding!.name = holdingJson["name"] as? String
            newHolding!.value = holdingJson["value"] as? NSNumber
            let currency = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: holdingJson["currency_code"]!, in: NSManagedObjectContext.mr_default())
            newHolding!.currency = currency

            newHoldings?.append(newHolding!)
        }
        return newHoldings
    }

}
