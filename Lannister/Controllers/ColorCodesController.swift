//
//  ColorCodesController.swift
//  Lannister
//
//  Created by André Sousa on 26/04/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit

protocol ColorCodesDelegate {
    func newColorCode(hex: String)
}

class ColorCodesController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    var delegate                 : ColorCodesDelegate!
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Color Codes"
        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        registerForKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(aNotification:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(aNotification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWasShown(aNotification: NSNotification) {
        let info = aNotification.userInfo as! [String: AnyObject],
        kbSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size,
        contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height
        
        if !aRect.contains(activeField!.frame.origin) {
            self.tableView.scrollRectToVisible(activeField!.frame, animated: true)
        }
    }
    
    @objc func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }

}


extension ColorCodesController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCodeCustomCellId", for: indexPath) as! ColorCodeCustomCell
            cell.colorCodeView.layer.borderWidth = 1
            cell.colorCodeView.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorCodePresetCellId", for: indexPath) as! ColorCodePresetCell
            if indexPath.row == 0 {
                cell.colorCodeLabel.text = "Gold - #FFBF00"
                cell.colorCodeView.backgroundColor = UIColor(red: 255/255, green: 191/255, blue: 0, alpha: 1)
            } else if indexPath.row == 1 {
                cell.colorCodeLabel.text = "Silver - #7C8288"
                cell.colorCodeView.backgroundColor = UIColor(red: 124/255, green: 130/255, blue: 136/255, alpha: 1)
            } else if indexPath.row == 2 {
                cell.colorCodeLabel.text = "Ruby - #E51522"
                cell.colorCodeView.backgroundColor = UIColor(red: 229/255, green: 21/255, blue: 34/255, alpha: 1)
            } else if indexPath.row == 3 {
                cell.colorCodeLabel.text = "Emmerald - #00B382"
                cell.colorCodeView.backgroundColor = UIColor(red: 0, green: 179/255, blue: 130/255, alpha: 1)
            } else if indexPath.row == 4 {
                cell.colorCodeLabel.text = "Saphire - #1538C0"
                cell.colorCodeView.backgroundColor = UIColor(red: 21/255, green: 56/255, blue: 192/255, alpha: 1)
            } else if indexPath.row == 5 {
                cell.colorCodeLabel.text = "Amethyst - #6F0DBE"
                cell.colorCodeView.backgroundColor = UIColor(red: 111/255, green: 13/255, blue: 190/255, alpha: 1)
            }
            return cell

        }
    }
}

extension ColorCodesController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! ColorCodePresetCell
        delegate.newColorCode(hex: cell.colorCodeLabel.text!)
        navigationController?.popViewController(animated: true)
    }
}

extension ColorCodesController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField.text! != "" {
            delegate.newColorCode(hex: textField.text!)
            navigationController?.popViewController(animated: true)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeField = nil
    }

}
