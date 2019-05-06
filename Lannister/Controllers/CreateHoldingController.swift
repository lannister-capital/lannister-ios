//
//  CreateHoldingController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

class CreateHoldingController: UIViewController {
    
    var holding : Holding!
    @IBOutlet weak var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        if holding != nil {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        } else {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
            navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    @objc func dismissVC() {

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! HoldingNameCell
        let holdingNameTextField = cell.holdingNameTextField
        
        if holdingNameTextField!.text == "" {
            let alert = UIAlertController(title: "Oops!", message: "Enter a name for this holding.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if holding == nil && HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: holdingNameTextField!.text!) != nil  {
            let alert = UIAlertController(title: "Oops!", message: "A holding with this name already exists.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        } else {
            
            var newHolding = HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: holdingNameTextField!.text!)
            if newHolding == nil {
                newHolding = HoldingManagedObject(context: NSManagedObjectContext.mr_default())
            }
            newHolding!.name = holdingNameTextField!.text
            newHolding!.currency = "€"
            
            let indexPath = IndexPath(row: 1, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! TotalValueCell
            let valueTextField = cell.totalValueTextField
            if let totalValue = Double(valueTextField!.text!) {
                newHolding!.value = totalValue
            } else {
                let alert = UIAlertController(title: "Oops!", message: "Invalid value.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let colorIndexPath = IndexPath(row: 3, section: 0)
            let colorCell = tableView.cellForRow(at: colorIndexPath) as! ColorCodeCell
            newHolding!.hex_color = colorCell.colorCodeLabel.text
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        if holding == nil {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
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
            if holding != nil {
                cell.holdingNameTextField.text = holding.name
            }
            return cell

        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalValueCellId", for: indexPath) as! TotalValueCell
            if holding != nil {
                cell.totalValueTextField.text = "\(holding.value!)"
            }
            return cell

        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCellId", for: indexPath) as! CurrencyCell

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCodeCellId", for: indexPath) as! ColorCodeCell
            if holding != nil {
                cell.colorCodeLabel.text = holding.hexColor
                cell.colorCodeView.backgroundColor = Colors.hexStringToUIColor(hex: holding.hexColor)
            }
            return cell

        }
    }
}

extension CreateHoldingController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
     
        if indexPath.row == 3 {
            let colorCodeVC = storyboard?.instantiateViewController(withIdentifier: "colorCodesVC") as! ColorCodesController
            colorCodeVC.delegate = self
            navigationController?.pushViewController(colorCodeVC, animated: true)
        }
    }
}

extension CreateHoldingController : ColorCodesDelegate {
    
    func newColorCode(hex: String) {
        let indexPath = IndexPath(row: 3, section: 0)
        let colorCodeCell = tableView.cellForRow(at: indexPath) as! ColorCodeCell
        colorCodeCell.colorCodeLabel.text = hex
        colorCodeCell.colorCodeView.backgroundColor = Colors.hexStringToUIColor(hex: hex)
    }
}
