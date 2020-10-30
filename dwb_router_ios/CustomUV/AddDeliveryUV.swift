//
//  AddDeliveryUV.swift
//  dwb_router_ios
//
//  Created by Aira on 7/30/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class AddDeliveryUV: UIView {

    @IBOutlet weak var checkUB: UIButton!
    @IBOutlet weak var regionLB: UILabel!
    @IBOutlet weak var deliveryCntTF: UITextField!
    
    var isChecked: Bool = false
    
    func initViewWithData(region: RegionModel) {
        regionLB.text = region.title
        regionLB.backgroundColor = UIColor.hexStringToUIColor(hex: region.color)
    }
    
    func getRegionTitle() -> String {
        return regionLB.text!
    }
    
    func getDeliveryCount() -> String {
        return deliveryCntTF.text!
    }
    
    func setDeliveryCount(val: String) {
        deliveryCntTF.text = val
    }
 
    @IBAction func onTapCheckUB(_ sender: Any) {
        if !isChecked {
            checkUB.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            checkUB.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        isChecked = !isChecked
    }
    
    func getCheckedState() -> Bool {
        return isChecked
    }
}
