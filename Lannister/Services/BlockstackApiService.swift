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
    
//    func sync(returns: @escaping(Response) -> Void) {
//
//    }
}
