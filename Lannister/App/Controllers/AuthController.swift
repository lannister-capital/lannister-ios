//
//  AuthController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Blockstack

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
            
            Blockstack.shared.signIn(redirectURI: "https://lannister.capital/redirect-mobile.html",
                                     appDomain: URL(string: "https://lannister.capital")!,
                                     manifestURI: nil,
                                     scopes: ["store_write", "publish_data"]) { authResult in
                                        switch authResult {
                                        case .success(let userData):
                                            print("Sign in SUCCESS", userData.profile?.name as Any)
                                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                                AppDelegate.shared.updateCurrencies()
                                                self.checkUserData()
                                            })
                                        case .cancelled:
                                            print("Sign in CANCELLED")
                                        case .failed(let error):
                                            print("Sign in FAILED, error: ", error ?? "n/a")
                                        }
            }
        })
    }
    
    @IBAction func syncLater() {
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            
            UserDefaults.standard.setValue("skippedAuth", forKey: "Auth")
            UserDefaults.standard.synchronize()
            AppDelegate.shared.updateCurrencies()
            AppDelegate.shared.rootViewController.switchToMainScreen()
        })
    }
    
    func checkUserData() {
        
        BlockstackApiService().checkUserData { hasData in
            if hasData {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    let alert = UIAlertController(title: "You already have holdings on your Blockstack account.",
                                                  message: "You have to choose between keeping the ones you already have on your Blockstack account or overwrite them with the ones you have locally on the iPhone app right now.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Use local data", style: UIAlertAction.Style.default, handler: { _ in
                        self.writeNewData()
                    }))
                    alert.addAction(UIAlertAction(title: "Use data from Blockstack", style: UIAlertAction.Style.default, handler: { _ in
                        self.readData()
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                self.writeNewData()
            }
        }
    }
    
    func writeNewData() {
        
        BlockstackApiService().send(returns: { errorMessage in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if errorMessage != nil {
                    let alert = UIAlertController(title: "Error",
                                                  message: errorMessage,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                AppDelegate.shared.rootViewController.switchToMainScreen()
            })
        })
    }
    
    func readData() {
        BlockstackApiService().sync(returns: { errorMessage in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if errorMessage != nil {
                    let alert = UIAlertController(title: "Error",
                                                  message: errorMessage,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                AppDelegate.shared.rootViewController.switchToMainScreen()
            })
        })
    }

}
