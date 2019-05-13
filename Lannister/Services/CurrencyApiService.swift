//
//  CurrencyAPIService.swift
//  Lannister
//
//  Created by André Sousa on 08/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Alamofire

class CurrencyApiService: BaseApiService {

    internal typealias Response = DataResponse<Any>?
    
    override init() {
        super.init()
    }
    
    var sharedManager = ApiManager.sharedManager
    
    func getCurrencies(returns: @escaping(Response) -> Void) {
        sharedManager.request("\(currencyBaseUrl)/latest", method: .get, parameters: nil)
            .validate()
            .responseJSON { (response) in returns(response) }
    }
    
    func getBTCfromEur(returns: @escaping(Response) -> Void) {
        sharedManager.request("\(currencyCryptoBaseUrl)/btc-eur", method: .get, parameters: nil)
            .validate()
            .responseJSON { (response) in returns(response) }
    }
    
    func getETHfromEur(returns: @escaping(Response) -> Void) {
        sharedManager.request("\(currencyCryptoBaseUrl)/eth-eur", method: .get, parameters: nil)
            .validate()
            .responseJSON { (response) in returns(response) }
    }


}
