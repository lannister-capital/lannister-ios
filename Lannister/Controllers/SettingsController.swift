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

class SettingsController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
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
}

extension SettingsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            if BioMetricAuthenticator.shared.faceIDAvailable() || BioMetricAuthenticator.shared.touchIDAvailable() {
                return 1
            }
            return 0
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 58))
        headerView.backgroundColor = UIColor.white
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 38, width: tableView.frame.size.width, height: 20))
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
        } else {
            titleLabel.text = "ABOUT"
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
                cell.nameLabel.text = "Sync with Blockstack"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-export")
                cell.nameLabel.text = "Export data"
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
        } else {
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
