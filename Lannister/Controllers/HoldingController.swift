//
//  HoldingController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

class HoldingController: UIViewController {

    var totalValue                      : Double!
    @IBOutlet weak var barView          : UIView!
    @IBOutlet weak var valueLabel       : UILabel!
    @IBOutlet weak var tableView        : UITableView!
    var holding                         : Holding!
    var transactions                    : [Transaction]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Holding"

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        barView.backgroundColor = Colors.hexStringToUIColor(hex: holding.hexColor)
        navigationItem.title = holding.name

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let editButton = UIBarButtonItem()
        editButton.title = "Edit"
        editButton.target = self
        editButton.action = #selector(edit)
        navigationItem.rightBarButtonItem = editButton
        
        valueLabel.text =  String(format: "€%.2f", holding.value!)
        
        updateTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTransactions()
    }
    
    func updateTransactions() {
        
        let transactionsManagedObjects = TransactionManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default())
        transactions = TransactionDto().transactions(from: transactionsManagedObjects as! [TransactionManagedObject])
        print("updateTransactions \(transactions.count)")
        tableView.reloadData()
    }
    
    @IBAction func createTransaction() {
        
    }
    
    @objc func edit() {
        
        let createHoldingVC = storyboard?.instantiateViewController(withIdentifier: "createHoldingVC") as! CreateHoldingController
        createHoldingVC.holding = holding
        createHoldingVC.totalValue = totalValue
        navigationController?.pushViewController(createHoldingVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTransaction" {
            let destinationVC = segue.destination as! CreateTransactionController
            destinationVC.holding = holding
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
            
            let transactionManagedObject = TransactionManagedObject.mr_findFirst(byAttribute: "identifier", withValue: transaction.identifier!, in: NSManagedObjectContext.mr_default())
            transactionManagedObject?.mr_deleteEntity(in: NSManagedObjectContext.mr_default())
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()

            transactions.remove(at: indexPath.row-1)

            tableView.deleteRows(at: [indexPath], with: .fade)
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "topCellId", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCellId", for: indexPath) as! TransactionCell
            let transaction = transactions[indexPath.row-1]
            cell.nameLabel.text = transaction.name
            if(transaction.type == "credit") {
                cell.valueLabel.text = String(format: "€%.2f", transaction.value!)
                cell.colorView.backgroundColor = Colors.hexStringToUIColor(hex: "00B382")
            } else {
                cell.valueLabel.text = String(format: "€%.2f", transaction.value!)
                cell.colorView.backgroundColor = Colors.hexStringToUIColor(hex: "E60243")
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
            navigationController?.pushViewController(transactionVC, animated: true)
        }
    }
}

