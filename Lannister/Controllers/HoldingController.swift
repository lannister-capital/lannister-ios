//
//  HoldingController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class HoldingController: UIViewController {

    @IBOutlet weak var collectionView   : UICollectionView!
    var holding                         : Holding!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Holding"

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        navigationItem.title = holding.name

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let editButton = UIBarButtonItem()
        editButton.title = "Edit"
        editButton.target = self
        editButton.action = #selector(edit)
        navigationItem.rightBarButtonItem = editButton
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
    
    @IBAction func createTransaction() {
        
    }
    
    @objc func edit() {
        
        let createHoldingVC = storyboard?.instantiateViewController(withIdentifier: "createHoldingVC") as! CreateHoldingController
        createHoldingVC.holding = holding
        navigationController?.pushViewController(createHoldingVC, animated: true)
    }

}

extension HoldingController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var sectionHeader = HoldingHeaderView()
        
        sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "holdingHeaderId", for: indexPath) as! HoldingHeaderView
        
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "transactionCellId", for: indexPath) as! TransactionCell
            return cell
        }
    }
}

extension HoldingController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

