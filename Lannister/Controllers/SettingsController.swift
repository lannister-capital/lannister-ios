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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-currency")
                cell.nameLabel.text = "Currency"
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-sync")
                cell.nameLabel.text = "Sync with Blockstack"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-export")
                cell.nameLabel.text = "Export data"
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-passcode")
                cell.nameLabel.text = "Change passcode"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-fingerprint")
                cell.nameLabel.text = "Sign in with Touch ID"
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-twitter")
                cell.nameLabel.text = "Twitter"
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-discord")
                cell.nameLabel.text = "Discord"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellId", for: indexPath) as! SettingsCell
                cell.logo.image = UIImage(named: "settings-github")
                cell.nameLabel.text = "Github"
                return cell
            }
        }
    }
}

extension SettingsController : UITableViewDelegate {
    
}
