//
//  DashboardController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class DashboardController: UIViewController {
    
    var navBarTitleLabel : UILabel!
    @IBOutlet weak var collectionView : UICollectionView!

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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIScreen.main.bounds.size.width < 375 {
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let itemWidth = 345*UIScreen.main.bounds.size.width/345
                let itemHeight = layout.itemSize.height
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.invalidateLayout()
            }
        }
    }
    
    @IBAction func createHolding() {
        
        let createHoldingNavVC = storyboard?.instantiateViewController(withIdentifier: "createHoldingNavVC")
        navigationController?.present(createHoldingNavVC!, animated: true, completion: nil)
    }
    
}

extension DashboardController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeader = DashboardHeaderView()
        
        sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dashboardHeaderId", for: indexPath) as! DashboardHeaderView
        
        if kind == UICollectionView.elementKindSectionHeader {
            
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
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let holdingVC = storyboard?.instantiateViewController(withIdentifier: "holdingVC") as! HoldingController
        navigationController?.pushViewController(holdingVC, animated: true)
    }
}
