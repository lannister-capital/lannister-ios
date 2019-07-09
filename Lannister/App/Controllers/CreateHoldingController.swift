//
//  CreateHoldingController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord
import BiometricAuthentication
import Blockstack

protocol EditHoldingDelegate {
    func updateHolding(newHolding: Holding)
}

class CreateHoldingController: UIViewController {
    
    var euroTotalValue              : Double!
    var holding                     : Holding!
    var selectedCurrency            : Currency!
    @IBOutlet weak var tableView    : UITableView!
    var delegate                    : EditHoldingDelegate!
    let impact                      = UIImpactFeedbackGenerator()
    let selection                   = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        if holding != nil {
            navigationItem.title = "Edit Holding"
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            selectedCurrency = holding.currency
        } else {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
            navigationItem.leftBarButtonItem = cancelButton
            let currency = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: CurrencyUserDefaults().getDefaultCurrencyCode()!, in: NSManagedObjectContext.mr_default())
            selectedCurrency = CurrencyDto().currency(from: currency!)
        }
    }
    
    @objc func removeKeyboard() {

        self.view.endEditing(true)
    }
    
    @objc func dismissVC() {

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save() {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! HoldingNameCell
        let holdingNameTextField = cell.holdingNameTextField
        
        if holdingNameTextField!.text == "" {
            impact.impactOccurred()
            let alert = UIAlertController(title: "Oops!", message: "Enter a name for this holding.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        if holding == nil && HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: holdingNameTextField!.text!) != nil  {
            impact.impactOccurred()
            let alert = UIAlertController(title: "Oops!", message: "A holding with this name already exists.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            
            let indexPath = IndexPath(row: 1, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! TotalValueCell
            let valueTextField = cell.totalValueTextField

            if valueTextField?.text?.doubleValue == nil {
                impact.impactOccurred()
                let alert = UIAlertController(title: "Oops!", message: "Invalid value.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:  NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            var newHoldingManagedObject : HoldingManagedObject

            if holding == nil {
                newHoldingManagedObject = HoldingManagedObject(context: NSManagedObjectContext.mr_default())
                newHoldingManagedObject.id = newHoldingManagedObject.objectID.uriRepresentation().lastPathComponent
            } else {
                newHoldingManagedObject = HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: holding.name!, in: NSManagedObjectContext.mr_default())!
            }
            newHoldingManagedObject.name = holdingNameTextField!.text
            
            let currencyManagedObject = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: selectedCurrency.code!, in: NSManagedObjectContext.mr_default())
            newHoldingManagedObject.currency = currencyManagedObject
            if let totalValue = valueTextField!.text!.doubleValue {
                newHoldingManagedObject.value = totalValue
            }
            
            let colorIndexPath = IndexPath(row: 3, section: 0)
            let colorCell = tableView.cellForRow(at: colorIndexPath) as! ColorCodeCell
            newHoldingManagedObject.hex_color = String(colorCell.colorCodeLabel.text!.suffix(7))
            
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

            if holding != nil {
                let newHolding = HoldingDto().holding(from: newHoldingManagedObject)
                if delegate != nil {
                    delegate.updateHolding(newHolding: newHolding)
                }
            }
        }
        
        var askBioAccess = false
        if HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default())?.count == 0 {
            askBioAccess = true
        }
        
        if askBioAccess {
            let alert = UIAlertController(title: "Biometric access", message: "Enable authentication.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:  NSLocalizedString("Yes, please!", comment: ""), style: .cancel, handler: { _ in
                
                BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                    switch result {
                    case .success( _):
                        UserDefaults.standard.set(true, forKey: "bioAccess")
                        UserDefaults.standard.synchronize()

                    case .failure(let error):
                        switch error {
                            
                        // device does not support biometric (face id or touch id) authentication
                        case .biometryNotAvailable:
                            self.showErrorAlert(message: error.message())
                            
                        // No biometry enrolled in this device, ask user to register fingerprint or face
                        case .biometryNotEnrolled:
                            self.showGotoSettingsAlert(message: error.message())
                            
                        // do nothing on canceled by system or user
                        case .fallback, .biometryLockedout, .canceledBySystem, .canceledByUser:
                            self.showPasscodeAuthentication(message: error.message())
                            
                        // show error for any other reason
                        default:
                            self.showErrorAlert(message: error.message())
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title:  NSLocalizedString("No, thank you!", comment: ""), style: .default, handler: { _ in
                self.dismiss()
            }))
            self.present(alert, animated: true, completion: nil)

        } else {
            dismiss()
        }
    }
    
    @IBAction func deleteHolding() {
        
        impact.impactOccurred()
        let alert = UIAlertController(title: "Delete Holding", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler:nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            let holdingManagedObject = HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: self.holding.name!)!
            holdingManagedObject.mr_deleteEntity(in: NSManagedObjectContext.mr_default())
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
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
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func dismiss() {
        
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
        return 5
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
                if selectedCurrency.code == "ETH" {
                    cell.cellIndicatorImageView.isHidden = false
                    cell.totalValueTextField.isHidden = true
                    cell.percentageLabel.isHidden = true
                    cell.currencyLabel.text = "Insert value or Import from Address"
                } else {
                    cell.cellIndicatorImageView.isHidden = true
                    cell.totalValueTextField.isHidden = false
                    cell.percentageLabel.isHidden = false
                    cell.totalValueTextField.text = String(format: "%.2f", holding.value!)
                    cell.percentageLabel.text = "\(String(format: "%.2f", Currencies.getEuroValue(value: holding.value, currency: holding.currency)/euroTotalValue*100))%"
                    cell.currencyLabel.text = holding.currency.symbol
                }
            } else {
                let currency = CurrencyManagedObject.mr_findFirst(byAttribute: "code", withValue: CurrencyUserDefaults().getDefaultCurrencyCode()!, in: NSManagedObjectContext.mr_default())
                cell.currencyLabel.text = currency!.symbol
            }
            return cell

        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCellId", for: indexPath) as! CurrencyCell
            cell.currencyNameLabel.text = selectedCurrency.symbol
            return cell

        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCodeCellId", for: indexPath) as! ColorCodeCell
            if holding != nil {
                cell.colorCodeLabel.text = holding.hexColor
                cell.colorCodeView.backgroundColor = Colors.hexStringToUIColor(hex: holding.hexColor)
            }
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCellId", for: indexPath)
            if holding == nil {
                cell.contentView.isHidden = true
            }
            return cell
        }
    }
}

extension CreateHoldingController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        removeKeyboard()
        
        let backItem = UIBarButtonItem()

        if indexPath.row == 1 && selectedCurrency.code == "ETH" {
            backItem.title = "New Holding"
            navigationItem.backBarButtonItem = backItem

            let ethCreateVC = storyboard?.instantiateViewController(withIdentifier: "ethCreateVC") as! ETHCreateHoldingController
            ethCreateVC.delegate = self
            let indexPathForTotalValue = IndexPath(row: 1, section: 0)
            let totalValueCell = tableView.cellForRow(at: indexPathForTotalValue) as! TotalValueCell
            if let holdingValue = totalValueCell.currencyLabel.text?.doubleValue {
                ethCreateVC.holdingValue = holdingValue
            }
            navigationController?.pushViewController(ethCreateVC, animated: true)
        }
        
        else if indexPath.row == 2 {
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem

            let currenciesVC = storyboard?.instantiateViewController(withIdentifier: "currenciesVC") as! CurrenciesController
            currenciesVC.delegate = self
            navigationController?.pushViewController(currenciesVC, animated: true)
        }
     
        else if indexPath.row == 3 {
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem

            let colorCodeVC = storyboard?.instantiateViewController(withIdentifier: "colorCodesVC") as! ColorCodesController
            colorCodeVC.delegate = self
            if holding?.hexColor != nil {
                colorCodeVC.hexString = holding.hexColor
            }
            navigationController?.pushViewController(colorCodeVC, animated: true)
        }
    }
}

extension CreateHoldingController : ColorCodesDelegate {
    
    func newColorCode(hex: String) {
        let indexPath = IndexPath(row: 3, section: 0)
        let colorCodeCell = tableView.cellForRow(at: indexPath) as! ColorCodeCell
        colorCodeCell.colorCodeLabel.text = hex
        colorCodeCell.colorCodeView.backgroundColor = Colors.hexStringToUIColor(hex: String(hex.suffix(7)))
    }
}

extension CreateHoldingController : CurrenciesDelegate {
    
    func selectedCurrency(currency: Currency) {
        
        selectedCurrency = currency
        
        let indexPath = IndexPath(row: 2, section: 0)
        let currencyCell = tableView.cellForRow(at: indexPath) as! CurrencyCell
        currencyCell.currencyNameLabel.text = currency.symbol
        
        let indexPathForTotalValue = IndexPath(row: 1, section: 0)
        let totalValueCell = tableView.cellForRow(at: indexPathForTotalValue) as! TotalValueCell
        if selectedCurrency.code == "ETH" {
            totalValueCell.cellIndicatorImageView.isHidden = false
            totalValueCell.totalValueTextField.isHidden = true
            totalValueCell.percentageLabel.isHidden = true
            totalValueCell.currencyLabel.text = "Insert value or Import from Address"
        } else {
            totalValueCell.cellIndicatorImageView.isHidden = true
            totalValueCell.changeLabel.isHidden = true
            totalValueCell.totalValueTextField.isHidden = false
            totalValueCell.percentageLabel.isHidden = false
            totalValueCell.currencyLabel.text = currency.symbol
        }
    }
}

extension CreateHoldingController : ETHDelegate {
    
    func importedAddress(address: String) {
        print("importedAddress \(address)")
        let indexPathForTotalValue = IndexPath(row: 1, section: 0)
        let totalValueCell = tableView.cellForRow(at: indexPathForTotalValue) as! TotalValueCell
        totalValueCell.cellIndicatorImageView.isHidden = false
        totalValueCell.totalValueTextField.isHidden = true
        totalValueCell.percentageLabel.isHidden = true
        totalValueCell.currencyLabel.text = "\(address.prefix(10))...\(address.suffix(4))"
        totalValueCell.changeLabel.isHidden = false
    }
    
    func insertedValue(value: Double) {
        print("insertedValue \(value)")
        let indexPathForTotalValue = IndexPath(row: 1, section: 0)
        let totalValueCell = tableView.cellForRow(at: indexPathForTotalValue) as! TotalValueCell
        totalValueCell.percentageLabel.isHidden = false
        totalValueCell.currencyLabel.text = "\(value)"
        totalValueCell.changeLabel.isHidden = false
    }
}

extension CreateHoldingController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
