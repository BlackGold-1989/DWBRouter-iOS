//
//  PostalCell.swift
//  dwb_router_ios
//
//  Created by Aira on 7/26/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications

class PostalCell: UICollectionViewCell {
    
    @IBOutlet weak var containUV: UIView!
    @IBOutlet weak var postalLB: UILabel!
    @IBOutlet weak var removeUIMG: UIImageView!
    
    var regionModel: RegionModel = RegionModel()
    var postal: String = ""
    
    override func awakeFromNib() {
        containUV.setShadowToUIView(radius: 1.0, type: .MEDIUM)
        let tapRemoveUIMG = UITapGestureRecognizer(target: self, action: #selector(onTapRemoveUIMG))
        removeUIMG.addGestureRecognizer(tapRemoveUIMG)
    }
    
    @objc func onTapRemoveUIMG() {
        for i in 0..<regionModel.postal.count {
            if regionModel.postal[i] == postal {
                regionModel.postal.remove(at: i)
                break
            }
        }
        FireManager.firebaseRef.addRegion(model: regionModel, success: {(result) in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes verwijderd postcode.", dismissDelay: 2.0)
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Verwijderen van post is mislukt.", dismissDelay: 2.0)
            }
        })
    }
    
    func initCell(model: RegionModel, value: String) {
        regionModel = model
        postal = value
        postalLB.text = value
        containUV.backgroundColor = UIColor.hexStringToUIColor(hex: model.color)
        
    }
}
