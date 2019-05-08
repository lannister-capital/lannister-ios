//
//  ApiManager.swift
//  Lannister
//
//  Created by André Sousa on 08/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Alamofire

class ApiManager: SessionManager {
    
    class var sharedManager: ApiManager {
        struct Static {
            static var sharedInstance = ApiManager(configuration: URLSessionConfiguration.default,
                                                   delegate: SessionDelegate.init(),
                                                   serverTrustPolicyManager: nil)
        }
        return Static.sharedInstance
    }
}
