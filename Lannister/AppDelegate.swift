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
    var isCheckingAuth      = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: "db")
        
        updateHoldingsAttributes()
        
        if CurrencyUserDefaults().getDefaultCurrencyCode() == nil {
            // we were saving default currency with the "name" attribute on first versions
            if CurrencyUserDefaults().getDefaultCurrencyName() != nil {
                if let currency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: CurrencyUserDefaults().getDefaultCurrencyName()!, in: NSManagedObjectContext.mr_default()) {
                    CurrencyUserDefaults().setDefaultCurrency(code: currency.code!)
                } else {
                    CurrencyUserDefaults().setDefaultCurrency(code: "USD")
                }
            } else {
                CurrencyUserDefaults().setDefaultCurrency(code: "USD")
            }
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
        if backgroundBlurView != nil {
            checkAuthentication()
        }
        if (UserDefaults.standard.object(forKey: "Auth") != nil) {
            updateCurrencies()
            updateBalances()
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
            if bioAccess == true && !isCheckingAuth {
                
                isCheckingAuth = true
                blurBackground()
                BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                    
                    switch result {
                    case .success( _):
                        print("Authentication Successful")
                        self.isCheckingAuth = false
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
                self!.isCheckingAuth = false
                self!.removeBackgroundBlur()
            case .failure(let error):
                print(error.message())
                self!.showPasscodeAuthentication(message: message)
            }
        }
    }
    
    func updateHoldingsAttributes() {
        
        let holdingsManagedObjects = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default()) as! [HoldingManagedObject]
        for holdingManagedObject in holdingsManagedObjects {
            if holdingManagedObject.id == nil {
                holdingManagedObject.id = holdingManagedObject.objectID.uriRepresentation().lastPathComponent
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
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
        
        var australianDollarCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "australian dollar")
        if australianDollarCurrency == nil {
            australianDollarCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        australianDollarCurrency!.name = "australian dollar"
        australianDollarCurrency!.symbol = "$"
        australianDollarCurrency!.code = "AUD"

        var canadianDollarCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "canadian dollar")
        if canadianDollarCurrency == nil {
            canadianDollarCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        canadianDollarCurrency!.name = "canadian dollar"
        canadianDollarCurrency!.symbol = "$"
        canadianDollarCurrency!.code = "CAD"

        var danishKroneCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "danish krone")
        if danishKroneCurrency == nil {
            danishKroneCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        danishKroneCurrency!.name = "danish krone"
        danishKroneCurrency!.symbol = "kr"
        danishKroneCurrency!.code = "DKK"

        var japaneseYenCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "japanese yen")
        if japaneseYenCurrency == nil {
            japaneseYenCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        japaneseYenCurrency!.name = "japanese yen"
        japaneseYenCurrency!.symbol = "¥"
        japaneseYenCurrency!.code = "JPY"

        var newZealandDollarCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "new Zealand dollar")
        if newZealandDollarCurrency == nil {
            newZealandDollarCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        newZealandDollarCurrency!.name = "new Zealand dollar"
        newZealandDollarCurrency!.symbol = "$"
        newZealandDollarCurrency!.code = "NZD"

        var norwegianKroneCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "norwegian krone")
        if norwegianKroneCurrency == nil {
            norwegianKroneCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        norwegianKroneCurrency!.name = "norwegian krone"
        norwegianKroneCurrency!.symbol = "kr"
        norwegianKroneCurrency!.code = "NOK"

        var singaporeDollarCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "singapore dollar")
        if singaporeDollarCurrency == nil {
            singaporeDollarCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        singaporeDollarCurrency!.name = "singapore dollar"
        singaporeDollarCurrency!.symbol = "$"
        singaporeDollarCurrency!.code = "SGD"

        var swedishKronaCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "swedish krona")
        if swedishKronaCurrency == nil {
            swedishKronaCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        swedishKronaCurrency!.name = "swedish krona"
        swedishKronaCurrency!.symbol = "kr"
        swedishKronaCurrency!.code = "SEK"

        var swissFrancCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "swiss franc")
        if swissFrancCurrency == nil {
            swissFrancCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        swissFrancCurrency!.name = "swiss franc"
        swissFrancCurrency!.symbol = "Fr"
        swissFrancCurrency!.code = "CHF"

        
        var bitcoinCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "bitcoin")
        if bitcoinCurrency == nil {
            bitcoinCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
        }
        bitcoinCurrency!.name = "bitcoin"
        bitcoinCurrency!.symbol = "Ƀ"
        bitcoinCurrency!.code = "BTC"

        var etherCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "ethereum")
        if etherCurrency == nil {
            etherCurrency = CurrencyManagedObject.mr_findFirst(byAttribute: "name", withValue: "ether")
            if etherCurrency == nil {
                etherCurrency = CurrencyManagedObject(context: NSManagedObjectContext.mr_default())
            }
        }
        etherCurrency!.name = "ether"
        etherCurrency!.symbol = "⬨"
        etherCurrency!.code = "ETH"

        
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
                if let australianDollarValue = currenciesArray["AUD"] as? Double {
                    australianDollarCurrency?.euro_rate = australianDollarValue
                }
                if let canadianDollarValue = currenciesArray["CAD"] as? Double {
                    canadianDollarCurrency?.euro_rate = canadianDollarValue
                }
                if let danishKroneValue = currenciesArray["DKK"] as? Double {
                    danishKroneCurrency?.euro_rate = danishKroneValue
                }
                if let japaneseYenValue = currenciesArray["JPY"] as? Double {
                    japaneseYenCurrency?.euro_rate = japaneseYenValue
                }
                if let newZealandDollarValue = currenciesArray["NZD"] as? Double {
                    newZealandDollarCurrency?.euro_rate = newZealandDollarValue
                }
                if let norwegianKroneValue = currenciesArray["NOK"] as? Double {
                    norwegianKroneCurrency?.euro_rate = norwegianKroneValue
                }
                if let singaporeDollarValue = currenciesArray["SGD"] as? Double {
                    singaporeDollarCurrency?.euro_rate = singaporeDollarValue
                }
                if let swedishKronaValue = currenciesArray["SEK"] as? Double {
                    swedishKronaCurrency?.euro_rate = swedishKronaValue
                }
                if let swissFrancValue = currenciesArray["CHF"] as? Double {
                    swissFrancCurrency?.euro_rate = swissFrancValue
                }
                
                CurrencyApiService().getBTCfromEur(returns: { response in
                    switch (response!.result) {
                    case .success(let JSON):
                        
                        let ticker = (JSON as AnyObject).object(forKey: "ticker")! as! [String: Any]

                        if let btcValue = ticker["price"] as? String {
                            bitcoinCurrency?.euro_rate = btcValue.doubleValue!
                        }

                        CurrencyApiService().getETHfromEur(returns: { response in
                            switch (response!.result) {
                            case .success(let JSON):
                                
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                
                                let ticker = (JSON as AnyObject).object(forKey: "ticker")! as! [String: Any]
                                if let ethValue = ticker["price"] as? String {
                                    etherCurrency?.euro_rate = ethValue.doubleValue!
                                }

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
    
    func updateBalances() {
        
        // Filter holdings with addresses
        let predicate = NSPredicate(format: "address != nil")
        let holdings = HoldingManagedObject.mr_findAll(with: predicate, in: NSManagedObjectContext.mr_default()) as! [HoldingManagedObject]
        for holdingManagedObject in holdings {
            let holding = HoldingDto().holding(from: holdingManagedObject)
            // Get tokens from holding
            let predicateAddress = NSPredicate(format: "address == %@", holding.address!)
            let tokenManagedObjects = TokenManagedObject.mr_findAll(with: predicateAddress, in: NSManagedObjectContext.mr_default()) as! [TokenManagedObject]
            for tokenManagedObject in tokenManagedObjects {
                WalletUseCase(with: WalletRepositoryImpl()).getBalanceOfToken(address: holding.address!, erc20TokenAddress: ERC20ContractsList.dai.rawValue, success: { balance in
                    DispatchQueue.main.async {
                        // Update token balance
                        tokenManagedObject.value = balance
                        NSManagedObjectContext.mr_default().mr_saveToPersistentStore(completion: { (_, error) in
                            if error == nil {
                                print("updated token")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateHoldings"), object: nil)
                            }
                        })
                    }
                }) { error in
                    print("could not get balance")
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


