//
//  BioAccessController.swift
//  Lannister
//
//  Created by André Sousa on 07/05/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import Foundation
import UIKit
import BiometricAuthentication

let CancelTitle     =   "Cancel"
let OKTitle         =   "OK"
typealias AlertViewController = UIAlertController

struct AlertAction {
    
    var title: String = ""
    var type: UIAlertAction.Style? = .default
    var enable: Bool? = true
    var selected: Bool? = false
    
    init(title: String, type: UIAlertAction.Style? = .default, enable: Bool? = true, selected: Bool? = false) {
        self.title = title
        self.type = type
        self.enable = enable
        self.selected = selected
    }
}

extension UIAlertController {
}

extension UIViewController {
    
    // Show Alert or Action sheet
    func getAlertViewController(type: UIAlertController.Style, with title: String?, message: String?, actions:[AlertAction], showCancel: Bool , actionHandler:@escaping ((_ title: String) -> ())) -> AlertViewController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: type)
        
        // items
        var actionItems: [UIAlertAction] = []
        
        // add actions
        for (index, action) in actions.enumerated() {
            
            let actionButton = UIAlertAction(title: action.title, style: action.type!, handler: { (actionButton) in
                actionHandler(actionButton.title ?? "")
            })
            
            actionButton.isEnabled = action.enable!
            if type == .actionSheet { actionButton.setValue(action.selected, forKey: "checked") }
            actionButton.setAssociated(object: index)
            
            actionItems.append(actionButton)
            alertController.addAction(actionButton)
        }
        
        // add cancel button
        if showCancel {
            let cancelAction = UIAlertAction(title: CancelTitle, style: .cancel, handler: { (action) in
                actionHandler(action.title!)
            })
            alertController.addAction(cancelAction)
        }
        return alertController
    }

    
    func showAlert(title: String, message: String) {
        
        let okAction = AlertAction(title: OKTitle)
        let alertController = getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: false) { (button) in
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoginSucessAlert() {
        showAlert(title: "Success", message: "Login successful")
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Error", message: message)
    }
    
    func showGotoSettingsAlert(message: String) {
        let settingsAction = AlertAction(title: "Go to settings")
        
        let alertController = getAlertViewController(type: .alert, with: "Error", message: message, actions: [settingsAction], showCancel: true, actionHandler: { (buttonText) in
            if buttonText == CancelTitle { return }
            
            // open settings
            let url = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:])
            }
            
        })
        present(alertController, animated: true, completion: nil)
    }
    
    // show passcode authentication
    func showPasscodeAuthentication(message: String) {
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
            switch result {
            case .success( _):
                self?.showLoginSucessAlert() // passcode authentication success
            case .failure(let error):
                print(error.message())
            }
        }
    }

}

/// NSObject associated object
public extension NSObject {
    
    /// keys
    private struct AssociatedKeys {
        static var descriptiveName = "associatedObject"
    }
    
    /// set associated object
    @objc func setAssociated(object: Any) {
        objc_setAssociatedObject(self, &AssociatedKeys.descriptiveName, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// get associated object
    @objc func associatedObject() -> Any? {
        return objc_getAssociatedObject(self, &AssociatedKeys.descriptiveName)
    }
}
