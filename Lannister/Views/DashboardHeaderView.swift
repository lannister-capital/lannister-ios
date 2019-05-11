//
//  DashboardHeaderView.swift
//  Lannister
//
//  Created by André Sousa on 27/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Charts

class DashboardHeaderView: UICollectionReusableView {
 
    @IBOutlet weak var numberOfHoldingsLabel    : UILabel!
    @IBOutlet weak var totalValueLabel          : UILabel!
    @IBOutlet weak var pieChartView             : PieChartView!
}
