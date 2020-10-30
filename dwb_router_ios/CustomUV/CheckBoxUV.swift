//
//  CheckBoxUV.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class CheckBoxUV: UIView {
    @IBOutlet weak var checkUIMG: UIImageView!
    @IBOutlet weak var regionLB: UILabel!
    @IBOutlet weak var contentUV: UIView!
    
    var regionModel: RegionModel = RegionModel()
    
    func initWithRegionModel(model: RegionModel, color: UIColor) {
        self.regionModel = model
        let contentUVGesture = UITapGestureRecognizer(target: self, action: #selector(onTapContentUV))
        contentUV.addGestureRecognizer(contentUVGesture)
        
        regionLB.text = regionModel.title
        contentUV.backgroundColor = color
        
        changeStatus()
    }
    
    func changeStatus() {
        if regionModel.isCheck {
            checkUIMG.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            checkUIMG.image = UIImage(systemName: "circle")
        }
    }
    
    @objc func onTapContentUV() {
        regionModel.isCheck = !regionModel.isCheck
        changeStatus()
    }
    
}
