//
//  PdfVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/23/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import PDFKit

class PdfVC: UIViewController {
 
    var url: Data?
    override func viewDidLoad() {
        super.viewDidLoad()

        let pdfView = PDFView(frame: view.bounds)
        pdfView.autoScales = true
        view.addSubview(pdfView)

        if let data = url {
          pdfView.document = PDFDocument(data: data)
        }
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapPrinterUB(_ sender: Any) {
        let printVC = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: [:])
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.orientation = UIPrintInfo.Orientation.portrait
        printInfo.jobName = "Sample"
        printVC.printInfo = printInfo
        printVC.printingItem = url

        printVC.present(animated: true) { (controller, completed, error) in
            if(!completed && error != nil){
                NSLog("Print failed - %@", error!.localizedDescription)
            }
            else if(completed) {
                NSLog("Print succeeded")
            }
        }
    }
    
}
