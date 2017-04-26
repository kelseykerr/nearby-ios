//
//  QRGeneratorViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 11/11/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

protocol QRGeneratorViewDelegate: class {
    
    func next()
    
    func generateCancelled()
    
}

class QRGeneratorViewController: UIViewController {

    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var qrCodeLabel: UILabel!
    @IBOutlet var forgotBtn: UIButton!
    
    weak var delegate: QRGeneratorViewDelegate?
    var transaction: NBTransaction?
    
    var qrImage: CIImage?
    var qrCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generateQRCode()
    }

    func generateQRCode() {
        let transactionId = (transaction?.id)!
        NBTransaction.fetchTransactionCode(id: transactionId) { result in
            print("Result:")
            print(result.value)
            self.loadQRCode(code: result.value!)
        }
    }
    
    func loadQRCode(code: String) {
        self.qrCode = code
        
        self.qrCodeLabel.text = code
        
        if qrImage == nil {
            let data = qrCode?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrImage = filter?.outputImage
            
//            qrImageView.image = UIImage(ciImage: qrImage!)
            
            let scaleX = qrImageView.frame.size.width / (qrImage?.extent.size.width)!
            let scaleY = qrImageView.frame.size.height / (qrImage?.extent.size.height)!
            
            let transformedImage = qrImage?.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            qrImageView.image = UIImage(ciImage: transformedImage!)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.next()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.generateCancelled()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgotBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let navVC = storyboard.instantiateViewController(
            withIdentifier: "ForgotToScanNavigationController") as? UINavigationController else {
                assert(false, "Misnamed view controller")
                return
        }
        let forgotVC = (navVC.childViewControllers[0] as! ForgotToScanViewController)
        forgotVC.transaction = transaction
        self.present(navVC, animated: true, completion: nil)
    }
}
