//
//  RoosterCell.swift
//  dwb_router_ios
//
//  Created by Aira on 6/22/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications

protocol RoosterCellDelegate{
    func onRoosterCellDelegate (model: CheckListModel)
    func onRemoveHistoryDelegate()
    func onEditHistoryDelegate()
    func onGoRoosterDetailDelegate(model: CheckListModel)
}

class RoosterCell: UIView {

    @IBOutlet weak var weekLB: UILabel!
    @IBOutlet weak var dayLB: UILabel!
    @IBOutlet weak var monthLB: UILabel!
    @IBOutlet weak var containDataUV: UIView!
    @IBOutlet weak var addUV: UIView!
    
    var delegate: RoosterCellDelegate?
    
    var strDate: String = ""
    
    var deliveryModels: [CheckListModel] = [CheckListModel]()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Utils.gUser?.type != "owner" {
            addUV.frame.size.width = 0.0
        }
    }
    
    func initCell(models: [CheckListModel]) {
        deliveryModels = models
        
        weekLB.text = models[0].week
        dayLB.text = models[0].day
        monthLB.text = models[0].month
        
        if models.first?.region == "" {
            return
        }
        
        var posY: CGFloat = 4.0
        for model in models {
            var cellY: CGFloat = posY
            var height = CGFloat(model.region.components(separatedBy: ",").count) * 25.0 + 4.0
            if (height < 66.0) {
                height = 66.0
            }
            
            let deliveryUV = Bundle.main.loadNibNamed("DeliveryUV", owner: self, options: nil)?.first as! DeliveryUV
            deliveryUV.frame = CGRect(x: 2.0, y: cellY, width: containDataUV.frame.width - 4.0, height: height)
            
            deliveryUV.layoutIfNeeded()
            deliveryUV.needsUpdateConstraints()
            deliveryUV.delegate = self
            containDataUV.addSubview(deliveryUV)
            
            cellY += height + 4.0
            posY = cellY
            let delta = (height - CGFloat(model.region.components(separatedBy: ",").count) * 25.0) / 2.0
            deliveryUV.initWithData(model: model, delta: delta)
        }
    }
    @IBAction func onTapAddDeliveryUB(_ sender: Any) {
        if Utils.gUser?.type != "owner" {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "You can not add.", dismissDelay: 2.0)
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AddDeliveryVC") as! AddDeliveryVC
        vc.date = deliveryModels[0].day + "-" + deliveryModels[0].numMonth + "-" + deliveryModels[0].year
        vc.delegate = self
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
}

extension RoosterCell: AddDeliveryDialogDelegate {
    func onAddDeliveryDailog(model: CheckListModel) {
        var deliveryModel: CheckListModel = CheckListModel()
        deliveryModel = model
        deliveryModel.year = deliveryModels[0].year
        deliveryModel.month = deliveryModels[0].month
        deliveryModel.week = deliveryModels[0].week
        deliveryModel.numMonth = deliveryModels[0].numMonth
        deliveryModel.day = deliveryModels[0].day
        delegate?.onRoosterCellDelegate(model: deliveryModel)
    }
}

extension RoosterCell: DeliveryUVDelegate {
    func onRemoveHistory() {
        delegate?.onRemoveHistoryDelegate()
    }
    
    func onTapStatisticUVDelegate(model: CheckListModel) {
        delegate?.onGoRoosterDetailDelegate(model: model)
    }
    
    func onEditHistory() {
        delegate?.onEditHistoryDelegate()
    }
}
