//
//  DonationsController.swift
//  Lannister
//
//  Created by André Sousa on 14/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class DonationsController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    var btcAddress = "3HbYALZzQYCzeNHvSFkW7JG5dEGHWbnV2j"
    var ethAddress = "0x291268FcF2c6c686fd542376Bf6Ea926fCA63C91"
    var daiAddress = "0x394a29F426F6505d40854ABb730D1c8DE29C8C87"

    override func viewDidLoad() {
        super.viewDidLoad()


        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)

        navigationItem.title = "Donate"
    }
    

}

extension DonationsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "donationsCellId", for: indexPath) as! DonationCell
        if indexPath.row == 0 {
            cell.currencyLabel.text = "BTC address"
            cell.addressLabel.text = btcAddress
        } else if indexPath.row == 1 {
            cell.currencyLabel.text = "ETH address"
            cell.addressLabel.text = ethAddress
        } else {
            cell.currencyLabel.text = "DAI address"
            cell.addressLabel.text = daiAddress
        }
        return cell
    }
}

extension DonationsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            UIPasteboard.general.string = btcAddress
        } else if indexPath.row == 1 {
            UIPasteboard.general.string = ethAddress
        } else {
            UIPasteboard.general.string = daiAddress
        }

        let cell = tableView.cellForRow(at: indexPath) as! DonationCell
        cell.copyLabel.text = "Copied"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            cell.copyLabel.text = "Copy"
        })
    }
}
