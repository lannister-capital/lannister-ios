//
//  CreateTransactionController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

class CreateTransactionController: UIViewController {

    @IBOutlet weak var tableView    : UITableView!
    var transaction                 : Transaction!
    var holding                     : Holding!
    var tap                         : UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        if tap == nil {
            tap = UITapGestureRecognizer(target: self, action: #selector(removeKeyboard))
            navigationController!.view.addGestureRecognizer(tap)
        }
    }
    
    @objc func removeKeyboard() {
        if tap != nil {
            navigationController!.view.removeGestureRecognizer(tap)
        }
        tap = nil
        self.view.endEditing(true)
    }

    
    @IBAction func save() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! TransactionNameCell
        let transactionNameTextField = cell.transactionNameTextField
        
        if transactionNameTextField!.text == "" {
            let alert = UIAlertController(title: "Oops!", message: "Enter a name for this transaction.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        var newTransaction : TransactionManagedObject
        if transaction == nil {
            newTransaction = TransactionManagedObject(context: NSManagedObjectContext.mr_default())
            let totalNumberOfTransactions = TransactionManagedObject.mr_findAll()
            newTransaction.identifier = "\(totalNumberOfTransactions!.count)"
        } else {
            newTransaction = TransactionManagedObject.mr_findFirst(byAttribute: "id", withValue: transaction.identifier!, in: NSManagedObjectContext.mr_default())!
        }
        newTransaction.name = transactionNameTextField!.text
        newTransaction.type = "credit"
        let holdingManagedObject = HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: holding.name!, in: NSManagedObjectContext.mr_default())
        newTransaction.holding = holdingManagedObject
        
        let indexPathValue = IndexPath(row: 2, section: 0)
        let cellForValue = tableView.cellForRow(at: indexPathValue) as! TotalValueCell
        let valueTextField = cellForValue.totalValueTextField
        if let totalValue = Double(valueTextField!.text!) {
            newTransaction.value = totalValue
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Invalid value.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        navigationController?.popViewController(animated: true)
    }
}

extension CreateTransactionController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionNameCellId", for: indexPath) as! TransactionNameCell
            
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "typeCellId", for: indexPath) as! TotalValueCell
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "valueCellId", for: indexPath) as! TotalValueCell
            
            return cell
        }
    }
}

extension CreateTransactionController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        removeKeyboard()
    }
}

extension CreateTransactionController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
