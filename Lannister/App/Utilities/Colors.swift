//
//  Colors.swift
//  Lannister
//
//  Created by André Sousa on 05/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

struct Colors {

    static func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func isCustomColor(hex: String) -> Bool {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if cString == "FFBF00" {
            return false
        } else if cString == "7C8288" {
            return false
        } else if cString == "E51522" {
            return false
        } else if cString == "00B382" {
            return false
        } else if cString == "1538C0" {
            return false
        } else if cString == "6F0DBE" {
            return false
        }
        
        return true
    }
}
