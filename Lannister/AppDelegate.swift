//
//  AppDelegate.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import MagicalRecord
import BiometricAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window              : UIWindow?
    var backgroundBlurView  : UIView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: "db")
        
        if CurrencyUserDefaults().getDefaultCurrencyName() == nil {
            CurrencyUserDefaults().setDefaultCurrency(name: "dollar")
        }
        
        checkAuthentication()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if let bioAccess = UserDefaults.standard.object(forKey: "bioAccess") as? Bool {
            if bioAccess == true {
                blurBackground()
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        checkAuthentication()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (UserDefaults.standard.object(forKey: "Auth") != nil) {
            updateCurrencies()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: RootController {
        return window!.rootViewController as! RootController
    }
    
    func checkAuthentication() {
        if let bioAccess = UserDefaults.standard.object(forKey: "bioAccess") as? Bool {
            if bioAccess == true {
                
                blurBackground()
                BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                    
                    switch result {
                    case .success( _):
                        print("Authentication Successful")
                        self.removeBackgroundBlur()
                    case .failure(let error):
                        print("Authentication Failed")
                        self.showPasscodeAuthentication(message: error.message())
                    }
                }
            }
        }
    }
    
    func blurBackground() {
        
        if backgroundBlurView == nil {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            backgroundBlurView = UIVisualEffectView(effect: blurEffect)
            backgroundBlurView!.frame = rootViewController.view.bounds
            backgroundBlurView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            rootViewController.view.addSubview(backgroundBlurView!)
        }
    }
    
    func removeBackgroundBlur() {
        backgroundBlurView?.removeFromSuperview()
        backgroundBlurView = nil
    }
    
    func showPasscodeAuthentication(message: String) {
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
            switch result {
            case .success( _):
                print("Authentication Successful")
                self!.removeBackgroundBlur()
            case .failure(let error):
                print(error.message())
                self!.showPasscodeAuthentication(message: message)
            }
        }
    }
    
    func updateCurrencies() {
                
        let currencies = CurrencyManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default())
        
        let showAlert = currencies!.count == 0

        var euroCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "euro")
        if euroCurrency == nil {
            euroCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        euroCurrency!.name = "euro"
        euroCurrency!.symbol = "€"
        euroCurrency!.code = "EUR"
        euroCurrency!.euro_rate = 1
        
        var dollarCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "dollar")
        if dollarCurrency == nil {
            dollarCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        dollarCurrency!.name = "dollar"
        dollarCurrency!.symbol = "$"
        dollarCurrency!.code = "USD"

        var poundCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "pound")
        if poundCurrency == nil {
            poundCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        poundCurrency!.name = "pound"
        poundCurrency!.symbol = "£"
        poundCurrency!.code = "GBP"
        
        var bitcoinCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "bitcoin")
        if bitcoinCurrency == nil {
            bitcoinCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        bitcoinCurrency!.name = "bitcoin"
        bitcoinCurrency!.symbol = "Ƀ"
        bitcoinCurrency!.code = "BTC"

        var ethereumCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "ethereum")
        if ethereumCurrency == nil {
            ethereumCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        ethereumCurrency!.name = "ethereum"
        ethereumCurrency!.symbol = "⬨"
        ethereumCurrency!.code = "ETH"

        
        // fetch euro_rate
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        CurrencyApiService().getCurrencies { (response) in
            
            switch (response!.result) {
            case .success(let JSON):
                print("JSON \(JSON)")
                let currenciesArray = (JSON as AnyObject).object(forKey: "rates")! as! [String: Any]
                if let dollarValue = currenciesArray["USD"] as? Double {
                    dollarCurrency?.euro_rate = dollarValue
                }
                if let poundValue = currenciesArray["GBP"] as? Double {
                    poundCurrency?.euro_rate = poundValue
                }
                
                CurrencyApiService().getBTCfromEur(returns: { response in
                    switch (response!.result) {
                    case .success(let JSON):
                        
                        print("btc json \(JSON)")
                        
                        let ticker = (JSON as AnyObject).object(forKey: "ticker")! as! [String: Any]
                        print("btc ticker \(ticker)")

                        if let btcValue = ticker["price"] as? String {
                            print("btc btcValue \(btcValue)")

                            bitcoinCurrency?.euro_rate = btcValue.doubleValue!
                        }

                        CurrencyApiService().getETHfromEur(returns: { response in
                            switch (response!.result) {
                            case .success(let JSON):
                                
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                
                                let ticker = (JSON as AnyObject).object(forKey: "ticker")! as! [String: Any]
                                if let ethValue = ticker["price"] as? String {
                                    ethereumCurrency?.euro_rate = ethValue.doubleValue!
                                }

                                print("saved currencies")

                                NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: { (_, error) in
                                    
                                    if error == nil {
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateHoldings"), object: nil)
                                    }
                                })
                                
                            case .failure(let error):
                                print("error fetching eth \(error.localizedDescription)")
                                if showAlert {
                                    self.showError(errorTitle: "Oops!", errorMessage: "Unable to fetch currencies")
                                }
                            }
                        })
                        
                    case .failure(let error):
                        print("error fetching btc \(error.localizedDescription)")
                        if showAlert {
                            self.showError(errorTitle: "Oops!", errorMessage: "Unable to fetch currencies")
                        }
                    }
                })
                
            case .failure(let error):
                print("error fetching currencies \(error.localizedDescription)")
                if showAlert {
                    self.showError(errorTitle: "Oops!", errorMessage: "Unable to fetch currencies")
                }
            }
        }

    }
    
    func showError(errorTitle: String, errorMessage: String) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        if let rootController = UIApplication.topViewController() {
            let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            rootController.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(top)
            } else if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
}


