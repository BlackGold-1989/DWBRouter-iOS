//
//  DeliveryUV.swift
//  dwb_router_ios
//
//  Created by Aira on 7/28/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications

protocol DeliveryUVDelegate {
    func onRemoveHistory()
    func onTapStatisticUVDelegate(model: CheckListModel)
    func onEditHistory()
}

class DeliveryUV: UIView {
    
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var carLB: UILabel!
    @IBOutlet weak var removeUB: UIButton!
    @IBOutlet weak var statisticUV: UIView!
    @IBOutlet weak var removeUBWidth: NSLayoutConstraint!
    @IBOutlet weak var editUB: UIButton!
    @IBOutlet weak var editUBWidth: NSLayoutConstraint!
    
    var delegate: DeliveryUVDelegate?
    
    var checkmodel: CheckListModel = CheckListModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapStatisticUV = UITapGestureRecognizer(target: self, action: #selector(onTapStatisticUV))
        statisticUV.addGestureRecognizer(tapStatisticUV)
        
        if Utils.gUser?.type != "owner" {
            removeUB.isHidden = true
            removeUBWidth.constant = 0.0
            editUB.isHidden = true
            editUBWidth.constant = 0.0
            return
        }
    }
    
    func initWithData(model: CheckListModel, delta: CGFloat) {
        
        checkmodel = model
        
        FireManager.firebaseRef.getUserInfo(id: model.userid, success: {(user) in
            self.nameLB.text = user.name
        })
        FireManager.firebaseRef.getCarById(id: model.carid, success: {(carModel) in
            self.carLB.text = carModel.name
        })
        
        let regions = model.region.components(separatedBy: ",")
        let colors = model.color.components(separatedBy: ",")
        let amount = model.amount.components(separatedBy: ",")
        
        let widthStatisticUV = statisticUV.frame.width
        
        var posY: CGFloat = delta - 2.0
        for i in 0..<regions.count {
            let deliveryItemUV = Bundle.main.loadNibNamed("DeliveryItem", owner: self, options: nil)?.first as! DeliveryItem
            deliveryItemUV.frame = CGRect(x: 0.0, y: posY, width: widthStatisticUV, height: 25.0)
            statisticUV.addSubview(deliveryItemUV)
            posY += 25.0
            
            deliveryItemUV.layoutIfNeeded()
            deliveryItemUV.needsUpdateConstraints()
            
            deliveryItemUV.initWithData(color: colors[i], region: regions[i], amount: amount[i])
        }
    }
    @IBAction func onTapRemoveUB(_ sender: Any) {
        if Utils.gUser?.type != "owner" {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "You can not remove.", dismissDelay: 2.0)
            return
        }
        FireManager.firebaseRef.removeDelivery(userid: checkmodel.userid, year: checkmodel.year, month: checkmodel.numMonth, day: checkmodel.day, deliveryid: checkmodel.id, success: {(result) in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes Verwijder geschiedenis.", dismissDelay: 2.0)
                self.delegate?.onRemoveHistory()
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan geschiedenis niet verwijderen.", dismissDelay: 2.0)
            }
        })
    }
    
    @IBAction func onTapEditUB(_ sender: Any) {
        if Utils.gUser?.type != "owner" {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "You can not add.", dismissDelay: 2.0)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "EditDeliveryVC") as! EditDeliveryVC
        vc.model = checkmodel
        vc.delegate = self
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    @objc func onTapStatisticUV() {
        if checkmodel.userid == "" {
            return
        }
        delegate?.onTapStatisticUVDelegate(model: checkmodel)
    }
}

extension DeliveryUV: EditDeliveryDialogDelegate {
    func onEditDeliveryDailog(model: CheckListModel) {
        FireManager.firebaseRef.editDelivery(model: model, success: {(result) in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes Update geschiedenis.", dismissDelay: 2.0)
                self.delegate?.onEditHistory()
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Mislukt Updategeschiedenis.", dismissDelay: 2.0)
            }
        })
    }
}
