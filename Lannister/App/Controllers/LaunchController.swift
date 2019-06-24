//
//  LaunchController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class LaunchController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.object(forKey: "Auth") == nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                AppDelegate.shared.rootViewController.switchToAuthScreen()
            })
        } else {
            AppDelegate.shared.rootViewController.switchToMainScreen()
        }
    }
}
