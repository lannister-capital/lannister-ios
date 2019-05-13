//
//  DashboardController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord
import Charts

class DashboardController: UIViewController {
    
    var navBarTitleLabel                        : UILabel!
    @IBOutlet weak var collectionView           : UICollectionView!
    @IBOutlet weak var emptyStateContainerView  : UIView!
    var holdings                                : [Holding]! = []
    var totalValue                              : Double! = 0
    var euroTotalValue                          : Double! = 0
    var sortKey                                 = "amount"
    var pieChartDataEntries                     = [PieChartDataEntry]()
    var pieChartDataColors                      = [UIColor]()
    var pieChartLegendEntries                   = [LegendEntry]()

    
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
        
        if UserDefaults.standard.object(forKey: "sortKey") != nil {
            sortKey = UserDefaults.standard.object(forKey: "sortKey") as! String
        }
        
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
            if sortKey == "amount" {
                holdings = holdings.sorted { $0.value! > $1.value! }
            } else {
                holdings = holdings.sorted { $0.name! < $1.name! }
            }
            euroTotalValue = 0
            pieChartDataEntries.removeAll()
            pieChartDataColors.removeAll()
            pieChartLegendEntries.removeAll()
            for holding in holdings {

                euroTotalValue += Currencies.getEuroValue(value: holding.value, currency: holding.currency)
                var legendTitle = holding.name
                if pieChartDataEntries.count > 7 {
                    legendTitle = "..."
                }
                let pieChartDataEntry = PieChartDataEntry(value: Currencies.getEuroValue(value: holding.value, currency: holding.currency), label: legendTitle)
                pieChartDataEntries.append(pieChartDataEntry)
                pieChartDataColors.append(Colors.hexStringToUIColor(hex: holding.hexColor))
//                if pieChartLegendEntries.count < 7 {
//                    let legendEntry = LegendEntry(label: holding.name, form: .default, formSize: 6, formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: Colors.hexStringToUIColor(hex: holding.hexColor))
//                    pieChartLegendEntries.append(legendEntry)
//                } else if pieChartLegendEntries.count == 7 {
//                    let legendEntry = LegendEntry(label: "...", form: .default, formSize: 6, formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1))
//                    pieChartLegendEntries.append(legendEntry)
//                }
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
    
    @IBAction func showSortOptions() {
        
        let alert = UIAlertController(title: "",
                                      message: "Sort Holdings",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "By Name", style: UIAlertAction.Style.default, handler: { _ in
            self.sortKey = "name"
            UserDefaults.standard.setValue("name", forKey: "sortKey")
            UserDefaults.standard.synchronize()
            self.holdings = self.holdings.sorted { $0.name! < $1.name! }
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "By Amount", style: UIAlertAction.Style.default, handler: { _ in
            self.sortKey = "amount"
            UserDefaults.standard.setValue("amount", forKey: "sortKey")
            UserDefaults.standard.synchronize()
            self.holdings = self.holdings.sorted { $0.value! > $1.value! }
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
                print("Currencies.getDefaultCurrencySymbol() \(Currencies.getDefaultCurrencySymbol())")
                sectionHeader.totalValueLabel.text = String(format: "%@%.0f", Currencies.getDefaultCurrencySymbol(), totalValue)
            } else {
                sectionHeader.totalValueLabel.text = "$ --"
            }
            sectionHeader.numberOfHoldingsLabel.text = "\(holdings.count) holdings"
            sectionHeader.pieChartView.chartDescription?.text = ""
            let attributedString = NSAttributedString(string: "%",
                                                             attributes: [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 20)!,
                                                                           NSAttributedString.Key.foregroundColor: UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)])
            sectionHeader.pieChartView.centerAttributedText = attributedString
            sectionHeader.pieChartView.drawHoleEnabled = true
            sectionHeader.pieChartView.holeColor = UIColor.clear
            sectionHeader.pieChartView.drawEntryLabelsEnabled = false
            sectionHeader.pieChartView.holeRadiusPercent = 0.80
            
            let legend = sectionHeader.pieChartView.legend
//            legend.entries = pieChartLegendEntries
            legend.font = UIFont(name: "AvenirNext-DemiBold", size: 12)!
            legend.textColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
            sectionHeader.pieChartView.legend.wordWrapEnabled = false

            sectionHeader.pieChartView.legend.form = .square //Illustration: original, square, line
            sectionHeader.pieChartView.legend.formSize = 6 // icon size
            sectionHeader.pieChartView.legend.formToTextSpace = 8 //text interval
//            sectionHeader.pieChartView.legend.yEntrySpace = 11 //text interval
            sectionHeader.pieChartView.legend.horizontalAlignment = .right
            sectionHeader.pieChartView.legend.verticalAlignment = .center
            sectionHeader.pieChartView.legend.orientation = .vertical

            let chartDataSet = PieChartDataSet(entries: pieChartDataEntries, label: nil)
            chartDataSet.colors = pieChartDataColors
            chartDataSet.drawValuesEnabled = false
            let chartData = PieChartData(dataSet: chartDataSet)
            sectionHeader.pieChartView.data = chartData
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCellId", for: indexPath) as! DashboardTopCell
            cell.sortButton.semanticContentAttribute = .forceRightToLeft
            let attributedString = NSMutableAttributedString(string: "Sort by:",
                                                             attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 42/255, green: 54/255, blue: 74/255, alpha: 1)])
            var sortWord = "Amount"
            if sortKey == "name" {
                sortWord = "Name"
            }
            attributedString.append(NSMutableAttributedString(string: " \(sortWord)",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]))
            cell.sortButton.setAttributedTitle(attributedString, for: .normal)
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
