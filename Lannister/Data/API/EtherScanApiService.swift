//
//  EtherScanApiService.swift
//  Lannister
//
//  Created by Andre Sousa on 17/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Alamofire

class EtherScanApiService: NSObject {
    
    internal typealias Response = DataResponse<Any>?
    
    var sharedManager = APIManager.sharedManager
    
    let baseURL = "https://api.etherscan.io/api"
    
    // module=account&action=txlist&address=0xddbd2b932c763ba5b1b7ae3b362eac3e8d40121a&startblock=0&endblock=99999999&sort=asc&apikey=YourApiKeyToken
    
    func getTransactions(params: Parameters?, returns: @escaping (Response) -> Void) {
        sharedManager.request("\(baseURL)", method: .get, parameters: params).validate().responseJSON { response in returns(response) }
    }
}

