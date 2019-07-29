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

    override init() {
        super.init()
    }

    func send(returns: @escaping(String?) -> Void) {
        
        let holdingsManagedObjects = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default()) as! [HoldingManagedObject]
        let holdingsArray = json(fromObjects: holdingsManagedObjects)
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let lannisterDictionary = ["db_version": versionString, "holdings": holdingsArray] as [String : Any]
        guard let data = try? JSONSerialization.data(withJSONObject: lannisterDictionary, options: []) else {
            return
        }
        let jsonString = String(data: data, encoding: String.Encoding.utf8)!
        print("jsonString \(jsonString)")
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
                print("responseString \(String(describing: responseString))")
                let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                if let parsedResponse = responseString!.parseJSONString as? [String: Any] {
                    if let version = parsedResponse["db_version"] as? String {
                        print("blockstack version \(version)")
                        if version != versionString {
                            let errorMessage = "You're using on old version of the app. Please update the app on the App Store to be able to sync your holdings."
                            returns(errorMessage)
                        } else {
                            if let parsedHoldings = parsedResponse["holdings"] as? Array<Any> {
                                print("parsedHoldings \(String(describing: parsedHoldings))")
                                let holdings = self.parseHoldings(holdings: parsedHoldings as NSArray)
                                print("new holdings \(String(describing: holdings))")
                                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                                returns(nil)
                            }
                        }
                    }
                }
                print("error \(String(describing: error?.localizedDescription))")
                returns(error?.localizedDescription)
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
