//
//  CreateHoldingController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class CreateHoldingController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismiss() {
        
        dismiss(animated: true, completion: nil)
    }
}

extension CreateHoldingController : UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "holdingNameCellId", for: indexPath) as! HoldingNameCell

            return cell

        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalValueCellId", for: indexPath) as! TotalValueCell

            return cell

        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCellId", for: indexPath) as! CurrencyCell

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCodeCellId", for: indexPath) as! ColorCodeCell

            return cell

        }
    }
}

extension CreateHoldingController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
