//
//  DashboardController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord

class DashboardController: UIViewController {
    
    var navBarTitleLabel                        : UILabel!
    @IBOutlet weak var collectionView           : UICollectionView!
    @IBOutlet weak var emptyStateContainerView  : UIView!
    var holdings                                : [Holding]! = []
    var totalValue                              : Double! = 0
    var euroTotalValue                          : Double! = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        updateHoldings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateHoldings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if UIScreen.main.bounds.size.width < 375 {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let itemWidth = UIScreen.main.bounds.size.width/375*345
                let itemHeight = layout.itemSize.height
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.invalidateLayout()
            }
        }
    }
    
    func updateHoldings() {
        
        let holdingsManagedObjects = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default())
        if holdingsManagedObjects?.count == 0 {
            emptyStateContainerView.isHidden = false
            emptyStateContainerView.isUserInteractionEnabled = true
            view.bringSubviewToFront(emptyStateContainerView)
        } else {
            emptyStateContainerView.isHidden = true
            emptyStateContainerView.isUserInteractionEnabled = false
            view.sendSubviewToBack(emptyStateContainerView)
            collectionView.isUserInteractionEnabled = true
            holdings = HoldingDto().holdings(from: holdingsManagedObjects as! [HoldingManagedObject])
            euroTotalValue = 0
            for holding in holdings {
                euroTotalValue += Currencies.getEuroValue(value: holding.value, currency: holding.currency)
            }
            totalValue = euroTotalValue * Currencies.getDefaultCurrencyEuroRate()
            collectionView.reloadData()
        }
    }
    
    @IBAction func createHolding() {
        
        let createHoldingNavVC = storyboard?.instantiateViewController(withIdentifier: "createHoldingNavVC")
        navigationController?.present(createHoldingNavVC!, animated: true, completion: nil)
    }
    
    @IBAction func settings() {
        
        let settingsNavVC = storyboard?.instantiateViewController(withIdentifier: "settingsNavVC")
        navigationController?.present(settingsNavVC!, animated: true, completion: nil)
    }
    
}

extension DashboardController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return holdings.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeader = DashboardHeaderView()
        
        sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dashboardHeaderId", for: indexPath) as! DashboardHeaderView
        
        if kind == UICollectionView.elementKindSectionHeader {
            if totalValue > 0 {
                sectionHeader.totalValueLabel.text = String(format: "%@%.0f", Currencies.getDefaultCurrencySymbol(), totalValue)
            } else {
                sectionHeader.totalValueLabel.text = "$ --"
            }
            sectionHeader.numberOfHoldingsLabel.text = "\(holdings.count) holdings"
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCellId", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "holdingCellId", for: indexPath) as! HoldingCell
            
            let holding = holdings[indexPath.row-1]
            let currency = holding.currency
            cell.colorView.backgroundColor = Colors.hexStringToUIColor(hex: holding.hexColor)
            cell.nameLabel.text = holding.name
            let value = String(format: "%.2f", holding.value!)
            cell.valueLabel.text = "\(currency!.symbol!)\(value)"
            let percentage = String(format: "%.2f", Currencies.getEuroValue(value: holding.value, currency: holding.currency)/euroTotalValue*100)
            cell.percentageLabel.text = "\(percentage)%"
            
            let path = UIBezierPath(roundedRect:cell.colorView.bounds,
                                    byRoundingCorners:[.topLeft, .bottomLeft],
                                    cornerRadii: CGSize(width: 4, height:  4))

            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            cell.colorView.layer.mask = maskLayer
            
            cell.contentView.layer.cornerRadius = 4
            cell.contentView.layer.masksToBounds = true
            
            cell.layer.masksToBounds = false
            
            cell.contentView.backgroundColor = UIColor(red: 232/255, green: 235/255, blue: 244/255, alpha: 1)
            
            return cell
        }
    }
}

extension DashboardController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row > 0 {
            collectionView.deselectItem(at: indexPath, animated: true)
            
            let holding = holdings[indexPath.row-1]
            
            let holdingVC = storyboard?.instantiateViewController(withIdentifier: "holdingVC") as! HoldingController
            holdingVC.holding = holding
            holdingVC.euroTotalValue = euroTotalValue
            navigationController?.pushViewController(holdingVC, animated: true)
        }
    }
}
