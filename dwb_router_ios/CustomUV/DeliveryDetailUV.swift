//
//  DeliveryDetailUV.swift
//  dwb_router_ios
//
//  Created by Aira on 7/31/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class DeliveryDetailUV: UIView {

    @IBOutlet weak var monthLB: UILabel!
    @IBOutlet weak var weekLB: UILabel!
    @IBOutlet weak var dayLB: UILabel!
    @IBOutlet weak var staisticUV: UIView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var uiview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initViewData(model: CheckListModel, delta: CGFloat) {
        monthLB.text = model.month
        weekLB.text = model.week
        dayLB.text = model.day
        
        let regions = model.region.components(separatedBy: ",")
        let colors = model.color.components(separatedBy: ",")
        let amount = model.amount.components(separatedBy: ",")
        
        let widthStatisticUV = staisticUV.frame.width
        
        var posY: CGFloat = delta - 2.0
        for i in 0..<regions.count {
            let deliveryItemUV = Bundle.main.loadNibNamed("DeliveryItem", owner: self, options: nil)?.first as! DeliveryItem
            deliveryItemUV.frame = CGRect(x: 0.0, y: posY, width: widthStatisticUV, height: 25.0)
            staisticUV.addSubview(deliveryItemUV)
            posY += 25.0
            
            deliveryItemUV.layoutIfNeeded()
            deliveryItemUV.needsUpdateConstraints()
            deliveryItemUV.initWithData(color: colors[i], region: regions[i], amount: amount[i])
        }
    }
    

}
