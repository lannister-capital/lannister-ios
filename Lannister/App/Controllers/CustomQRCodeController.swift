//
//  CustomQRCodeController.swift
//  Lannister
//
//  Created by André Sousa on 09/07/2019.
//  Copyright © 2019 André Sousa. All rights reserved.
//

import UIKit
import QRCodeReader

protocol CustomQRCodeControllerDelegate {
    func scanned(result: QRCodeReaderResult?)
}

class CustomQRCodeController: UIViewController {
    
    var delegate                        : CustomQRCodeControllerDelegate!
    @IBOutlet weak var closeButton      : UIButton!
    @IBOutlet weak var scannerOverlay   : UIImageView!
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = false
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            self.dismiss(animated: true, completion: {
                self.delegate.scanned(result: result)
            })
        }
        
        self.addChild(readerVC)
        readerVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: UIScreen.main.bounds.size.height-183)
        view.addSubview(readerVC.view)
        readerVC.didMove(toParent: self)
        
        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(scannerOverlay)
    }
    
    @IBAction func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
}
