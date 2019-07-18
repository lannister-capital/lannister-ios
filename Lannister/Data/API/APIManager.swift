//
//  APIManager.swift
//  Lannister
//
//  Created by Andre Sousa on 17/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Alamofire

class APIManager: SessionManager {
    
    class var sharedManager: APIManager {
        struct Static {
            static var sharedInstance = APIManager(configuration: URLSessionConfiguration.default,
                                                   delegate: SessionDelegate.init(),
                                                   serverTrustPolicyManager: nil)
        }
        return Static.sharedInstance
    }
}
