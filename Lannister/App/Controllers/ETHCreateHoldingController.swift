//
//  ETHCreateHoldingController.swift
//  Lannister
//
//  Created by André Sousa on 08/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import QRCodeReader

protocol ETHDelegate {
    func importedAddress(address: String)
    func insertedValue(value: Double)
}

class ETHCreateHoldingController: UIViewController {
    
    @IBOutlet weak var valueTextField   : UITextField!
    @IBOutlet weak var tableView        : UITableView!
    var toolBar                         = UIToolbar()
    var delegate                        : ETHDelegate!
    var holdingValue                    : Double!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "ETH"

        navigationController!.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size: 18)!,
             NSAttributedString.Key.foregroundColor : UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)]
        navigationController?.navigationBar.tintColor = UIColor(red: 118/255, green: 134/255, blue: 162/255, alpha: 1)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if holdingValue != nil {
            valueTextField.text = "\(holdingValue!)"
        }
        
        let btnDone = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveValue))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearValue))

        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        toolBar.isUserInteractionEnabled = true
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.items = [clearButton, spaceButton, btnDone]
        
        valueTextField.inputAccessoryView = toolBar
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func removeKeyboard() {
        clearValue()
        self.view.endEditing(true)
    }
    
    @objc func clearValue() {
        valueTextField.text = ""
    }
    
    @objc func saveValue() {
        if let newValue = valueTextField.text?.doubleValue {
            delegate.insertedValue(value: newValue)
            navigationController?.popViewController(animated: true)
        }
    }

    func showInvalidAddressWarning() {
        
        DispatchQueue.main.async {
            let msg = "Invalid address"
            let alert = UIAlertController(title: "Error",
                                          message: msg,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func scanAction() {
        
        let customQRCodeController = storyboard?.instantiateViewController(withIdentifier: "customQRCodeVC") as! CustomQRCodeController
        customQRCodeController.delegate = self
        self.present(customQRCodeController, animated: true, completion: nil)
    }
}

extension ETHCreateHoldingController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "clipboardCellId", for: indexPath) as! ETHCell
            
            if let pasteboardString = UIPasteboard.general.string {
                let first2 = String(pasteboardString.prefix(2))
                if first2 == "0x" {
                    cell.addressLabel.text = UIPasteboard.general.string
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scanCellId", for: indexPath)
            return cell
        }
    }
}

extension ETHCreateHoldingController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            if let pasteboardString = UIPasteboard.general.string {
                let first2 = String(pasteboardString.prefix(2))
                if first2 == "0x" {
                    delegate.importedAddress(address: pasteboardString)
                    navigationController?.popViewController(animated: true)
                    return
                }
            }
            showInvalidAddressWarning()
            
        } else {
            scanAction()
        }
    }
}

extension ETHCreateHoldingController : CustomQRCodeControllerDelegate {
    
    func scanned(result: QRCodeReaderResult?) {
        
        if let resultString = result?.value {
            let first2 = String(resultString.prefix(2))
            let ethereumUrl = String(resultString.prefix(9))
            if first2 == "0x" {
                DispatchQueue.main.async {
                    self.delegate.importedAddress(address: resultString)
                    self.navigationController?.popViewController(animated: true)
                }
            } else if ethereumUrl == "ethereum:" {
                DispatchQueue.main.async {
                    let range = resultString.range(of: ethereumUrl)
                    self.delegate.importedAddress(address: String(resultString[range!.upperBound...]))
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                showInvalidAddressWarning()
            }
        }
    }
}
