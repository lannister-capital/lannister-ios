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

    @IBOutlet weak var barView          : UIView!
    @IBOutlet weak var collectionView   : UICollectionView!
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
        
        updateTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTransactions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIScreen.main.bounds.size.width < 414 {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let itemWidth = 414*UIScreen.main.bounds.size.width/414
                let itemHeight = layout.itemSize.height
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.invalidateLayout()
            }
        }
    }
    
    func updateTransactions() {
        
        let transactionsManagedObjects = TransactionManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default())
        transactions = TransactionDto().transactions(from: transactionsManagedObjects as! [TransactionManagedObject])
        print("updateTransactions \(transactions.count)")
        collectionView.reloadData()
    }
    
    @IBAction func createTransaction() {
        
    }
    
    @objc func edit() {
        
        let createHoldingVC = storyboard?.instantiateViewController(withIdentifier: "createHoldingVC") as! CreateHoldingController
        createHoldingVC.holding = holding
        navigationController?.pushViewController(createHoldingVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTransaction" {
            let destinationVC = segue.destination as! CreateTransactionController
            destinationVC.holding = holding
        }
    }
}

extension HoldingController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if transactions.count == 0 {
            return 1
        }
        return transactions.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeader = HoldingHeaderView()
        
        sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "holdingHeaderId", for: indexPath) as! HoldingHeaderView
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            sectionHeader.valueLabel.text =  String(format: "€%.2f", holding.value!)
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCellId", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "transactionCellId", for: indexPath) as! TransactionCell
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

extension HoldingController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row > 0 {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            let transaction = transactions[indexPath.row-1]
            
            let transactionVC = storyboard?.instantiateViewController(withIdentifier: "transactionVC") as! CreateTransactionController
            transactionVC.transaction = transaction
            transactionVC.holding = holding
            navigationController?.pushViewController(transactionVC, animated: true)
        }
    }
}

