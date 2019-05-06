//
//  SettingsController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

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
}

extension SettingsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 2
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
            titleLabel.text = "SECURITY"
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
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-sync")
                cell.nameLabel.text = "Sync with Blockstack"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-export")
                cell.nameLabel.text = "Export data"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-passcode")
                cell.nameLabel.text = "Change passcode"
                cell.cellIndicator.isHidden = false
                cell.currencyLabel.isHidden = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-fingerprint")
                cell.nameLabel.text = "Sign in with Touch ID"
                cell.cellIndicator.isHidden = true
                cell.currencyLabel.isHidden = true
                return cell
            }
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

            } else if indexPath.row == 1 {

            } else {

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
