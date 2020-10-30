//
//  OrderDetailCell.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

protocol OrderDetailCellDelegate {
    func didSelectCell(index: Int)
}

class OrderDetailCell: UITableViewCell {
    @IBOutlet weak var containerUV: UIView!
    @IBOutlet weak var idLB: UILabel!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var addressLB: UILabel!
    @IBOutlet weak var cityLB: UILabel!
    @IBOutlet weak var phoneLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var doneUB: UIButton!
    @IBOutlet weak var rightUIMG: UIImageView!
    @IBOutlet weak var checkUB: UIButton!
    @IBOutlet weak var checkUBWidth: NSLayoutConstraint!
    
    var order: OrderModel = OrderModel()
    var _index: Int = Int()
    var delegate: OrderDetailCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let containerUVGesture = UITapGestureRecognizer(target: self, action: #selector(onTapContainUV))
        containerUV.addGestureRecognizer(containerUVGesture)
        
        containerUV.setShadowToUIView(radius: 4.0, type: .MEDIUM)
        
        checkUBWidth.constant = 0.0
        checkUB.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(model: OrderModel, processing: String, index: Int, showCheckMark: Bool) {
        order = model
        _index = index
        
        if showCheckMark {
            checkUBWidth.constant = 24.0
            checkUB.isHidden = false
        } else {
            checkUBWidth.constant = 0.0
            checkUB.isHidden = true
        }
        
        for region in Utils.gRegions {
            if model.shippingPerson.region == region.title {
                containerUV.backgroundColor = UIColor.hexStringToUIColor(hex: region.color)
                break
            } else {
                containerUV.backgroundColor = .white
                continue
            }
        }
        
        
        idLB.text = "#" + model.orderNumber
        nameLB.text = model.shippingPerson.name
        addressLB.text = model.shippingPerson.street
        cityLB.text = model.shippingPerson.city
        phoneLB.text = model.shippingPerson.phone
        dateLB.text = model.datetime.components(separatedBy: " ")[0]
        
        if processing == "Processing" {
            rightUIMG.isHidden = false
            doneUB.isHidden = true
        } else {
            rightUIMG.isHidden = true
            doneUB.isHidden = false
        }
        
        if model.isCheckDeliver {
            checkUB.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            checkUB.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        
    }
    
    @objc func onTapContainUV() {
        if Utils.gProcessing[_index] == "Processing" {
            delegate?.didSelectCell(index: _index)
        } else {
            return
        }
    }
    
    @IBAction func onTapCheckUB(_ sender: Any) {
        if order.isCheckDeliver {
            checkUB.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            checkUB.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        }
        
        order.isCheckDeliver = !order.isCheckDeliver
    }
}
