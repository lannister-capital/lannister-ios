//
//  CreateTransactionController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord
import Blockstack

protocol CreateTransactionDelegate {
    func newTransaction(newHolding: Holding)
}

class CreateTransactionController: UIViewController {

    @IBOutlet weak var tableView    : UITableView!
    var transaction                 : Transaction!
    var holding                     : Holding!
    var transactionType             = ["Credit", "Debit"]
    var selectedTransaction         : String! = "Credit"
    var transactionPickerView       : UIPickerView!
    var toolBar                     = UIToolbar()
    var delegate                    : CreateTransactionDelegate!
    let impact                      = UIImpactFeedbackGenerator()
    let selection                   = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        transactionPickerView = UIPickerView(frame: CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: 200))
        transactionPickerView.delegate = self
        transactionPickerView.dataSource = self as UIPickerViewDataSource
        transactionPickerView.showsSelectionIndicator = true
        
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(removeKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        toolBar.isUserInteractionEnabled = true
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.items = [spaceButton, btnDone]
    }
    
    @objc func removeKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func save() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! TransactionNameCell
        let transactionNameTextField = cell.transactionNameTextField
        
        if transactionNameTextField!.text == "" {
            impact.impactOccurred()
            let alert = UIAlertController(title: "Oops!", message: "Enter a name for this transaction.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let indexPathValue = IndexPath(row: 2, section: 0)
        let cellForValue = tableView.cellForRow(at: indexPathValue) as! TotalValueCell
        let valueTextField = cellForValue.totalValueTextField
        if valueTextField?.text?.doubleValue == nil || valueTextField?.text?.doubleValue == 0 {
            impact.impactOccurred()
            let alert = UIAlertController(title: "Oops!", message: "Invalid value.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        print("save")
        
        var newTransaction : TransactionManagedObject
        if transaction == nil {
            newTransaction = TransactionManagedObject(context: NSManagedObjectContext.mr_default())
            newTransaction.id = newTransaction.objectID.uriRepresentation().lastPathComponent
        } else {
            newTransaction = TransactionManagedObject.mr_findFirst(byAttribute: "id", withValue: transaction.identifier!, in: NSManagedObjectContext.mr_default())!
        }

        newTransaction.name = transactionNameTextField!.text
        
        let holdingManagedObject = HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: holding.name!, in: NSManagedObjectContext.mr_default())
        newTransaction.holding = holdingManagedObject

        if selectedTransaction == "Credit" {
            newTransaction.type = "credit"
        } else {
            newTransaction.type = "debit"
        }
        
        if let totalValue = valueTextField!.text!.doubleValue {
            newTransaction.value = totalValue
            if selectedTransaction == "Credit" {
                print("totalValue \(totalValue)")
                if transaction == nil {
                    holdingManagedObject!.value = holdingManagedObject!.value + totalValue
                } else {
                    if transaction.type == "credit" {
                        holdingManagedObject!.value = holdingManagedObject!.value + (totalValue-transaction.value)
                    } else {
                        holdingManagedObject!.value = holdingManagedObject!.value + (totalValue+transaction.value)
                    }
                }
            } else {
                if transaction == nil {
                    holdingManagedObject!.value = holdingManagedObject!.value - totalValue
                } else {
                    if transaction.type == "debit" {
                        holdingManagedObject!.value = holdingManagedObject!.value - (totalValue-transaction.value)
                    } else {
                        holdingManagedObject!.value = holdingManagedObject!.value - (totalValue+transaction.value)
                    }
                }
            }

        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        selection.selectionChanged()
        
        if Blockstack.shared.isUserSignedIn() {
            BlockstackApiService().send { error in
                if error != nil {
                    self.impact.impactOccurred()
                    let msg = error!.localizedDescription
                    let alert = UIAlertController(title: "Error",
                                                  message: msg,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        print("holdingManagedObject!.value \(holdingManagedObject!.value)")
        
        if delegate != nil {
            delegate.newTransaction(newHolding: HoldingDto().holding(from: holdingManagedObject!))
        }
        
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
            if transaction != nil {
                cell.transactionNameTextField.text = transaction.name
            }
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "typeCellId", for: indexPath) as! TransactionTypeCell
            if transaction?.type == "debit" {
                cell.transactionTypeTextField.text = "Debit"
            }
            cell.transactionTypeTextField.inputView = transactionPickerView
            cell.transactionTypeTextField.inputAccessoryView = toolBar
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "valueCellId", for: indexPath) as! TotalValueCell
            cell.currencyLabel.text = holding.currency.symbol
            if transaction != nil {
                cell.totalValueTextField.text = "\(transaction.value!)"
            }
            return cell
        }
    }
}

extension CreateTransactionController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! TransactionTypeCell
            cell.transactionTypeTextField.becomeFirstResponder()
        } else {
            removeKeyboard()
        }
    }
}

extension CreateTransactionController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension CreateTransactionController : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return transactionType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return transactionType[row]
    }
}

extension CreateTransactionController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TransactionTypeCell
        cell.transactionTypeTextField.text = transactionType[row]
        selectedTransaction = transactionType[row]
    }
}
