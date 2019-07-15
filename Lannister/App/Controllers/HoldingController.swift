//
//  HoldingController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord
import Charts
import Blockstack
import web3swift

class HoldingController: UIViewController {

    var euroTotalValue                              : Double!
    @IBOutlet weak var barView                      : UIView!
    @IBOutlet weak var valueLabel                   : UILabel!
    @IBOutlet weak var defaultCurrencyValueLabel    : UILabel!
    @IBOutlet weak var pieChartViewTopConstraint    : NSLayoutConstraint!
    @IBOutlet weak var pieChartView                 : PieChartView!
    @IBOutlet weak var tableView                    : UITableView!
    var holding                                     : Holding!
    var transactions                                : [Transaction]! = []
    var pieChartDataEntries                         = [PieChartDataEntry]()
    var pieChartDataColors                          = [UIColor]()
    var numberFormatter                             = NumberFormatter()
    var percentFormatter                            = NumberFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Holding"
        
        // Set number formatter display
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 2
        
        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let editButton = UIBarButtonItem()
        editButton.title = "Edit"
        editButton.target = self
        editButton.action = #selector(editHolding)
        navigationItem.rightBarButtonItem = editButton
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        updateHolding()
        updatePieChart()
        updateTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTransactions()
    }
    
    func updateHolding() {
        
        navigationItem.title = holding.name
        barView.backgroundColor = Colors.hexStringToUIColor(hex: holding.hexColor)
        euroTotalValue = PortfolioUseCase(with: PortfolioRepositoryImpl()).getEuroTotalValue()
        barView.backgroundColor = Colors.hexStringToUIColor(hex: holding.hexColor)
        navigationItem.title = holding.name

        var holdingCurrency = holding.currency
        var holdingValue : Double? = holding.value
        if holding.address != nil {
            // Get ETH
            let predicateAddress = NSPredicate(format: "address == %@", holding.address!)
            let predicateCode = NSPredicate(format: "code == %@", "ETH")
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateAddress, predicateCode])
            
            let tokenManagedObject = TokenManagedObject.mr_findFirst(with: compoundPredicate, in: NSManagedObjectContext.mr_default())!
            let token = TokenDto().token(from: tokenManagedObject)
            holdingValue = token.value
            holdingCurrency = token.currency
        }

        let formattedNumber = numberFormatter.string(for: NSNumber(value: holdingValue!))
        valueLabel.text =  String(format: "%@%@", holdingCurrency!.symbol, formattedNumber ?? "--")
        
        if holdingCurrency!.symbol == Currencies.getDefaultCurrencySymbol() {
            // remove label
            if defaultCurrencyValueLabel != nil {
                defaultCurrencyValueLabel.removeFromSuperview()
                defaultCurrencyValueLabel = nil
            }
            pieChartViewTopConstraint.constant = 8
        } else {
            let euroValue = Currencies.getEuroValue(value: holdingValue!, currency: holdingCurrency!)
            let currencyValue = euroValue * Currencies.getDefaultCurrencyEuroRate()
            let formattedNumber = numberFormatter.string(for: NSNumber(value: currencyValue))
            defaultCurrencyValueLabel.text = String(format: "%@%@", Currencies.getDefaultCurrencySymbol(), formattedNumber ?? "--")
        }
    }
    
    func updatePieChart() {
        
        pieChartDataEntries.removeAll()
        pieChartDataColors.removeAll()

        var holdingCurrency = holding.currency
        var holdingValue : Double? = holding.value
        if holding.address != nil {
            // Get ETH
            let predicateAddress = NSPredicate(format: "address == %@", holding.address!)
            let predicateCode = NSPredicate(format: "code == %@", "ETH")
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateAddress, predicateCode])
            
            let tokenManagedObject = TokenManagedObject.mr_findFirst(with: compoundPredicate, in: NSManagedObjectContext.mr_default())!
            let token = TokenDto().token(from: tokenManagedObject)
            holdingValue = token.value
            holdingCurrency = token.currency
        }
        if holdingValue! < 0 {
            holdingValue = 0
        }

        let euroValue = Currencies.getEuroValue(value: holdingValue!, currency: holdingCurrency!)

        let pieChartDataEntry = PieChartDataEntry(value: euroValue, label: nil)
        pieChartDataEntries.append(pieChartDataEntry)
        pieChartDataColors.append(Colors.hexStringToUIColor(hex: holding.hexColor))

        let secondPieChartDataEntry = PieChartDataEntry(value: euroTotalValue-euroValue, label: nil)
        pieChartDataEntries.append(secondPieChartDataEntry)
        pieChartDataColors.append(UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 0.7))
        
        pieChartView.chartDescription?.text = ""
        let percentage = percentFormatter.string(for: NSNumber(value: euroValue/euroTotalValue*100))
        let attributedString = NSAttributedString(string: "\(percentage ?? "")%",
                                                  attributes: [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 20)!,
                                                                NSAttributedString.Key.foregroundColor: UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)])
        pieChartView.centerAttributedText = attributedString
        pieChartView.drawHoleEnabled = true
        pieChartView.holeColor = UIColor.clear
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.holeRadiusPercent = 0.80
        pieChartView.legend.enabled = false
        
        let chartDataSet = PieChartDataSet(entries: pieChartDataEntries, label: nil)
        chartDataSet.colors = pieChartDataColors
        chartDataSet.drawValuesEnabled = false
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChartView.data = chartData
    }
    
    func updateTransactions() {
        
        let transactionsManagedObjects = TransactionManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default())
        transactions = TransactionDto().transactions(from: transactionsManagedObjects as! [TransactionManagedObject])
        transactions = transactions.filter { $0.holding!.name == self.holding!.name }
        tableView.reloadData()
    }
    
    @IBAction func createTransaction() {
        
    }
    
    @objc func editHolding() {
        
        let createHoldingVC = storyboard?.instantiateViewController(withIdentifier: "createHoldingVC") as! CreateHoldingController
        createHoldingVC.holding = holding
        createHoldingVC.euroTotalValue = euroTotalValue
        createHoldingVC.delegate = self
        navigationController?.pushViewController(createHoldingVC, animated: true)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTransaction" {
            let destinationVC = segue.destination as! CreateTransactionController
            destinationVC.holding = holding
            destinationVC.delegate = self
        }
    }
}

extension HoldingController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactions.count == 0 {
            return 1
        }
        return transactions.count+1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let transaction = transactions[indexPath.row-1]
            
            let holdingManagedObject = HoldingManagedObject.mr_findFirst(byAttribute: "name", withValue: holding.name!, in: NSManagedObjectContext.mr_default())
            if transaction.type == "credit" {
                holdingManagedObject!.value = holdingManagedObject!.value!.doubleValue - transaction.value! as NSNumber
            } else {
                holdingManagedObject!.value = holdingManagedObject!.value!.doubleValue + transaction.value! as NSNumber
            }
            
            let transactionManagedObject = TransactionManagedObject.mr_findFirst(byAttribute: "id", withValue: transaction.identifier!, in: NSManagedObjectContext.mr_default())
            transactionManagedObject?.mr_deleteEntity(in: NSManagedObjectContext.mr_default())
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
            
            if Blockstack.shared.isUserSignedIn() {
                BlockstackApiService().send { error in
                    if error != nil {
                        let msg = error!.localizedDescription
                        let alert = UIAlertController(title: "Error",
                                                      message: msg,
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }

            transactions.remove(at: indexPath.row-1)
            
            holding = HoldingDto().holding(from: holdingManagedObject!)
            
            euroTotalValue = PortfolioUseCase(with: PortfolioRepositoryImpl()).getEuroTotalValue()
            updateHolding()
            updatePieChart()

            tableView.deleteRows(at: [indexPath], with: .fade)
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "topCellId", for: indexPath) as! HoldingTopCell
            cell.addButton.layer.cornerRadius = 4
            if holding.address != nil {
                cell.addButton.isHidden = true
                cell.addButton.isUserInteractionEnabled = false
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCellId", for: indexPath) as! TransactionCell
            let transaction = transactions[indexPath.row-1]
            cell.nameLabel.text = transaction.name
            let formattedNumber = numberFormatter.string(for: NSNumber(value: transaction.value!))
            if(transaction.type == "credit") {
                cell.valueLabel.text = "+ \(holding.currency!.symbol!)\(formattedNumber ?? "--")"
                cell.colorView.backgroundColor = Colors.hexStringToUIColor(hex: "00B382")
                cell.valueLabel.textColor = Colors.hexStringToUIColor(hex: "00B382")
            } else {
                cell.valueLabel.text = "- \(holding.currency!.symbol!)\(formattedNumber ?? "--")"
                cell.colorView.backgroundColor = Colors.hexStringToUIColor(hex: "E60243")
                cell.valueLabel.textColor = Colors.hexStringToUIColor(hex: "E60243")
            }
            return cell
        }
    }
    
}

extension HoldingController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row > 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let transaction = transactions[indexPath.row-1]
            
            let transactionVC = storyboard?.instantiateViewController(withIdentifier: "transactionVC") as! CreateTransactionController
            transactionVC.transaction = transaction
            transactionVC.holding = holding
            transactionVC.delegate = self
            navigationController?.pushViewController(transactionVC, animated: true)
        }
    }
}

extension HoldingController : EditHoldingDelegate {
    
    func updateHolding(newHolding: Holding) {
        
        holding = newHolding
        updateHolding()
        updatePieChart()
    }
}

extension HoldingController : CreateTransactionDelegate {
    
    func newTransaction(newHolding: Holding) {
        
        holding = newHolding
        updateHolding()
        updatePieChart()
    }
}
