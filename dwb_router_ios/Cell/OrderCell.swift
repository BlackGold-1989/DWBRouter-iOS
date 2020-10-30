//
//  OrderCell.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

protocol OrderCellDelegat {
    func didCheckOrder(isChecked: Bool, model: OrderModel)
}

class OrderCell: UITableViewCell {
    @IBOutlet weak var containUV: UIView!
    @IBOutlet weak var checkUIMG: UIImageView!
    @IBOutlet weak var idLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var priceLB: UILabel!
    @IBOutlet weak var orderNameLB: UILabel!
    @IBOutlet weak var orderCityLB: UILabel!
    @IBOutlet weak var orderAddrssLB: UILabel!
    
    var order: OrderModel = OrderModel()
    var delegate: OrderCellDelegat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let containGesture = UITapGestureRecognizer(target: self, action: #selector(onTapContainUV))
        contentView.addGestureRecognizer(containGesture)
        
        containUV.setShadowToUIView(radius: 4.0, type: .MEDIUM)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithCell(model: OrderModel) {
        
        order = model
        
        for region in Utils.gRegions {
            if model.shippingPerson.region == region.title {
                containUV.backgroundColor = UIColor.hexStringToUIColor(hex: region.color)
                break
            } else {
                containUV.backgroundColor = .white
                continue
            }
        }
        
//        if model.shippingPerson.region == AppConst.regions[1] {
//            containUV.backgroundColor = UIColor.mainRoosterRed()
//        } else if model.shippingPerson.region == AppConst.regions[2] {
//            containUV.backgroundColor = UIColor.mainRoosterBlue()
//        } else if model.shippingPerson.region == AppConst.regions[3] {
//            containUV.backgroundColor = UIColor.mainRoosterGreen()
//        } else if model.shippingPerson.region == AppConst.regions[4] {
//            containUV.backgroundColor = UIColor.mainRoosterYellow()
//        } else if model.shippingPerson.region == AppConst.regions[5] {
//            containUV.backgroundColor = UIColor.mainRoosterPink()
//        } else {
//            containUV.backgroundColor = .white
//        }
        
        idLB.text = "#" + model.orderNumber
        dateLB.text = model.deliveryDate
        priceLB.text = String(format: "€ %.2f", model.total)
        orderNameLB.text = model.shippingPerson.name
        orderCityLB.text = model.shippingPerson.city
        orderAddrssLB.text = model.shippingPerson.street
        if order.isCheck {
            checkUIMG.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            checkUIMG.image = UIImage(systemName: "circle")
        }
    }
    
    @objc func onTapContainUV() {
        if order.isCheck {
            checkUIMG.image = UIImage(systemName: "circle")
        } else {
            checkUIMG.image = UIImage(systemName: "checkmark.circle.fill")
        }
        order.isCheck = !order.isCheck
        
        delegate?.didCheckOrder(isChecked: order.isCheck, model: order)
    }
    
}
