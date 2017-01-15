//
//  QRGeneratorViewController.swift
//  Nearby
//
//  Created by Kei Sakaguchi on 11/11/16.
//  Copyright © 2016 Kei Sakaguchi. All rights reserved.
//

import UIKit

class QRGeneratorViewController: UIViewController {

    @IBOutlet var qrImageView: UIImageView!
    
    var qrImage: CIImage?
    var qrCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        qrCode = "1234ge8ngcigioswgcoineringcenrois"
        
        if qrImage == nil {
            let data = qrCode?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrImage = filter?.outputImage
            
            qrImageView.image = UIImage(ciImage: qrImage!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
