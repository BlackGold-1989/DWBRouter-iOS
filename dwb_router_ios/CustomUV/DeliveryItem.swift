//
//  DeliveryItemUV.swift
//  dwb_router_ios
//
//  Created by Aira on 7/28/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class DeliveryItem: UIView {

    @IBOutlet weak var cntLB: UILabel!
    @IBOutlet weak var itemUV: UIView!
    @IBOutlet weak var regionLB: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func initWithData(color: String, region: String, amount: String) {
        itemUV.backgroundColor = UIColor.hexStringToUIColor(hex: color)
//        itemHeight.constant = 25.0
        regionLB.text = region
        cntLB.text = amount
    }
}
