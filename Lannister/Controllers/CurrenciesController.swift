//
//  CurrenciesController.swift
//  Lannister
//
//  Created by Andre Sousa on 09/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class CurrenciesController: UIViewController {

    @IBOutlet weak var tableView    : UITableView!
    var currencies                  : [Currency]!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        navigationItem.title = "Currencies"
    }
        
}

extension CurrenciesController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCellId", for: indexPath) as! CurrencyCell
        let currency = currencies[indexPath.row]
        cell.currencyNameLabel.text = currency.name
        cell.currencySymbolLabel.text = currency.symbol
        return cell
    }
}

extension CurrenciesController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
