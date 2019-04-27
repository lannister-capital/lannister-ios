//
//  AuthController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

class AuthController: UIViewController {
    
    @IBOutlet weak var signInButton : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        signInButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        signInButton.layer.shadowOpacity = 0.3
        signInButton.layer.shadowRadius = 0.0
        signInButton.layer.masksToBounds = false
    }
    
    @IBAction func signIn() {
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            
            UserDefaults.standard.setValue("auth", forKey: "Auth")
            AppDelegate.shared.rootViewController.switchToMainScreen()
        })
    }
    
    @IBAction func syncLater() {
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            
            UserDefaults.standard.setValue("skippedAuth", forKey: "Auth")
            AppDelegate.shared.rootViewController.switchToMainScreen()
        })
    }
}
