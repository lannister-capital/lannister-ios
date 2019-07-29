//
//  SettingsController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import Groot
import MagicalRecord
import BiometricAuthentication
import Blockstack

class SettingsController: UIViewController {
    
    @IBOutlet weak var tableView    : UITableView!
    let selection                   = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func dismiss() {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SettingsCell {
            cell.bioAccessSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
            
            if let bioAccess = UserDefaults.standard.object(forKey: "bioAccess") as? Bool {
                if bioAccess == true {
                    cell.bioAccessSwitch.setOn(true, animated: true)
                }
            }
        }
    }
    
    @IBAction func bioAccessSwitch(_ sender: Any) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SettingsCell
        if cell.bioAccessSwitch.isOn {
             cell.bioAccessSwitch.setOn(true, animated: true)
        } else {
             cell.bioAccessSwitch.setOn(false, animated:true)
        }
    }
    
    @objc func stateChanged(switchState: UISwitch) {
        selection.selectionChanged()
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SettingsCell
        if cell.bioAccessSwitch.isOn {
            askBioAccess()
        } else {
            UserDefaults.standard.set(false, forKey: "bioAccess")
            UserDefaults.standard.synchronize()
        }
    }
    
    func askBioAccess() {
        
        let alert = UIAlertController(title: "Biometric access", message: "Enable authentication.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Yes, please!", comment: ""), style: .cancel, handler: { _ in
            
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                switch result {
                case .success( _):
                    UserDefaults.standard.set(true, forKey: "bioAccess")
                    UserDefaults.standard.synchronize()
                    
                case .failure(let error):
                    switch error {
                    // device does not support biometric (face id or touch id) authentication
                    case .biometryNotAvailable:
                        self.showErrorAlert(message: error.message())
                        
                    // No biometry enrolled in this device, ask user to register fingerprint or face
                    case .biometryNotEnrolled:
                        self.showGotoSettingsAlert(message: error.message())
                        
                    // do nothing on canceled by system or user
                    case .fallback, .biometryLockedout, .canceledBySystem, .canceledByUser:
                        self.showPasscodeAuthentication(message: error.message())

                    // show error for any other reason
                    default:
                        self.showErrorAlert(message: error.message())
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title:  NSLocalizedString("No, thank you!", comment: ""), style: .default, handler: { _ in
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! SettingsCell
            cell.bioAccessSwitch.setOn(false, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func turnOffSync() {
        Blockstack.shared.signUserOut()
    }
    
    func turnOnSync(cell: SettingsCell) {
        
        Blockstack.shared.signIn(redirectURI: "https://lannister.capital/redirect-mobile.html",
                                 appDomain: URL(string: "https://lannister.capital")!,
                                 manifestURI: nil,
                                 scopes: ["store_write", "publish_data"]) { authResult in
                                    switch authResult {
                                    case .success(let userData):
                                        print("Sign in SUCCESS", userData.profile?.name as Any)
                                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                            cell.nameLabel.text = "Logout of Blockstack"
                                            self.checkUserData()
                                        })
                                    case .cancelled:
                                        print("Sign in CANCELLED")
                                    case .failed(let error):
                                        print("Sign in FAILED, error: ", error ?? "n/a")
                                    }
        }
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
            if errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    let alert = UIAlertController(title: "Error",
                                                  message: errorMessage,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
    }
    
    func readData() {
        BlockstackApiService().sync(returns: { errorMessage in
            if errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    let alert = UIAlertController(title: "Error",
                                                  message: errorMessage,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        })
    }
}

extension SettingsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            if BioMetricAuthenticator.shared.faceIDAvailable() || BioMetricAuthenticator.shared.touchIDAvailable() {
                return 1
            }
            return 0
        } else if section == 2 {
            return 1
        } else if section == 3 {
            return 3
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 58))
        headerView.backgroundColor = UIColor.white
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 38, width: tableView.frame.size.width-30, height: 20))
        headerView.addSubview(titleLabel)
        titleLabel.textColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        if section == 0 {
            titleLabel.text = "LOCAL"
        } else if section == 1 {
            if BioMetricAuthenticator.shared.faceIDAvailable() || BioMetricAuthenticator.shared.touchIDAvailable() {
                titleLabel.text = "SECURITY"
            } else {
                titleLabel.text = ""
            }
        } else if section == 2 {
            titleLabel.text = "DONATE"
        } else if section == 3 {
            titleLabel.text = "ABOUT"
        } else {
            titleLabel.textAlignment = .center
            let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let buildString = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            titleLabel.text = "Version \(versionString)(\(buildString))"
        }
        return headerView
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-currency")
                cell.nameLabel.text = "Currency"
                cell.cellIndicator.isHidden = false
                cell.currencyLabel.isHidden = false
                cell.currencyLabel.text = Currencies.getDefaultCurrencySymbol()
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-sync")
                if Blockstack.shared.isUserSignedIn() {
                    cell.nameLabel.text = "Logout of Blockstack"
                } else {
                    cell.nameLabel.text = "Sync with Blockstack"
                }
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-export")
                cell.nameLabel.text = "Backup data"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            }
        } else if indexPath.section == 1 {
//            if indexPath.row == 0 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
//                cell.logo.image = UIImage(named: "settings-passcode")
//                cell.nameLabel.text = "Change passcode"
//                cell.cellIndicator.isHidden = false
//                cell.currencyLabel.isHidden = true
//                return cell
//            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-fingerprint")
                if BioMetricAuthenticator.shared.faceIDAvailable() {
                    cell.nameLabel.text = "Sign in with Face ID"
                }
                if BioMetricAuthenticator.shared.touchIDAvailable() {
                    cell.nameLabel.text = "Sign in with Touch ID"
                }
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                cell.bioAccessSwitch.isHidden = false
                cell.bioAccessSwitch.isUserInteractionEnabled = true
                return cell
//            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
            cell.logo.image = UIImage(named: "donations")
            cell.nameLabel.text = "Donations"
            cell.cellIndicator.isHidden = false
            cell.currencyLabel.isHidden = true
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-twitter")
                cell.nameLabel.text = "Twitter"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-discord")
                cell.nameLabel.text = "Discord"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-github")
                cell.nameLabel.text = "Github"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            }
        }
    }
}

extension SettingsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let currenciesVC = storyboard?.instantiateViewController(withIdentifier: "currenciesVC") as! CurrenciesController
                currenciesVC.delegate = self
                currenciesVC.shouldSetGlobalCurrency = true
                navigationController?.pushViewController(currenciesVC, animated: true)
            }
            else if indexPath.row == 1 {

                let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SettingsCell
                if Blockstack.shared.isUserSignedIn() {
                    cell.nameLabel.text = "Sync with Blockstack"
                    turnOffSync()
                } else {
                    turnOnSync(cell: cell)
                }
            }
            else {
                let lannisterManagedObjects = HoldingManagedObject.mr_findAll(in: NSManagedObjectContext.mr_default()) as! [HoldingManagedObject]
                let lannisterData = json(fromObjects: lannisterManagedObjects)
                guard let data = try? JSONSerialization.data(withJSONObject: lannisterData, options: []) else {
                    return
                }
                let jsonString = String(data: data, encoding: String.Encoding.utf8)
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileName = "Lannister"
                    let fileURL = dir.appendingPathComponent(fileName).appendingPathExtension("json")
                    do {
                        try jsonString!.write(to: fileURL, atomically: false, encoding: .utf8)
                    } catch {
                        print("Error fetching results for container")
                    }
                    let items = [fileURL]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    present(ac, animated: true)
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {

            } else {

            }
        } else if indexPath.section == 2 {
            let donationsVC = storyboard?.instantiateViewController(withIdentifier: "donationsVC")
            navigationController!.pushViewController(donationsVC!, animated: true)
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                UIApplication.shared.open(URL(string: "https://twitter.com/lannistercap")!, options: [:], completionHandler: nil)
            } else if indexPath.row == 1 {
                UIApplication.shared.open(URL(string: "https://discord.gg/kMTUpME")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string: "https://github.com/lannister-capital")!, options: [:], completionHandler: nil)
            }
        }
    }
}

extension SettingsController : CurrenciesDelegate {
    
    func selectedCurrency(currency: Currency) {
        let indexPath = IndexPath(row: 0, section: 0)
        let settingsCell = tableView.cellForRow(at: indexPath) as! SettingsCell
        settingsCell.currencyLabel.text = currency.symbol
    }
}
