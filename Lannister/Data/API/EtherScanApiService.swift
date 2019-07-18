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
    let apiKey = "GP7SEQH5PPAX47AGETTCU3ZHCMD3WRUP3F"
        
    func getTransactions(params: Parameters?, returns: @escaping (Response) -> Void) {
        sharedManager.request("\(baseURL)", method: .get, parameters: params).validate().responseJSON { response in returns(response) }
    }
}

