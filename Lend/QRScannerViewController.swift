//
//  QRScannerViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 2/4/17.
//  Copyright © 2017 Kei Sakaguchi. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRScannerViewDelegate: class {
    
    func scanned(transId: String, code: String) // scanned
    
    func scanCancelled()
    
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: QRScannerViewDelegate?
    var transaction: NBTransaction?
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var scanned = false
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
        
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
        
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
//            view.bringSubview(toFront: messageLabel)
//            view.bringSubview(toFront: topbar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.scanCancelled()
        self.dismiss(animated: true, completion: nil)
        print("cancelled")
    }
    
    @IBAction func manualButtonPressed(_ sender: UIBarButtonItem) {
        print("manual")
        
        let manualEntryAlertController = createManualEntryAlertController()
        self.present(manualEntryAlertController, animated: true) {
            // ...
        }
    }
    
    func createManualEntryAlertController() -> UIAlertController {
        
        let alertController = UIAlertController(title: nil, message: "Enter the transaction code:", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            if let alertController = alertController {
                let codeTextField = alertController.textFields![0] as UITextField
//                login(codeTextField.text)
                self.delegate?.scanned(transId: (self.transaction?.id!)!, code: codeTextField.text!)
                self.dismiss(animated: true, completion: nil)
            }
        }
        okAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addTextField { textField in
//            textField.placeholder = "XXXX-XXXX-XXXX-XXXX"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification in
                okAction.isEnabled = textField.text != ""
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            messageLabel.text = "No QR/barcode is detected"
            print("No QR/barcode is detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
//                messageLabel.text = metadataObj.stringValue
                print("\(metadataObj.stringValue)")
                
                if !scanned {
                    scanned = true
                    delegate?.scanned(transId: (transaction?.id!)!, code: metadataObj.stringValue)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}
