//
//  CarCell.swift
//  dwb_router_ios
//
//  Created by Aira on 7/25/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications

class CarCell: UITableViewCell {

    @IBOutlet weak var carName: UILabel!
    @IBOutlet weak var carRegdate: UILabel!
    @IBOutlet weak var containUV: UIView!
    @IBOutlet weak var removeUIMG: UIImageView!
    @IBOutlet weak var editUIMG: UIImageView!
    
    var model: CarServiceModel = CarServiceModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containUV.setShadowToUIView(radius: 6.0, type: .MEDIUM)
        
        let tapRemoveGesture = UITapGestureRecognizer(target: self, action: #selector(onTapRemoveUIMG))
        removeUIMG.addGestureRecognizer(tapRemoveGesture)
        
        let tapEditGesture = UITapGestureRecognizer(target: self, action: #selector(onTapEditUIMG))
        editUIMG.addGestureRecognizer(tapEditGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func onTapRemoveUIMG() {
        FireManager.firebaseRef.removeCar(model: self.model, success: {(result) in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes auto verwijderen", dismissDelay: 2.0)
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan auto niet verwijderen", dismissDelay: 2.0)
            }
        })
    }
    
    @objc func onTapEditUIMG() {
        let alert = UIAlertController(title: "", message: "Auto-informatie bewerken", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.borderStyle = .roundedRect
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned alert] _ in
            let textField = alert.textFields![0]
            if textField.text!.count > 0 {
                self.model.name = textField.text!
                FireManager.firebaseRef.editCar(model: self.model, success: {(result) in
                    if result == "success" {
                        CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes auto bewerken.", dismissDelay: 2.0)
                    } else {
                        CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Auto bewerken mislukt.", dismissDelay: 2.0)
                    }
                })
            } else {
                CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Voer de naam van de auto in.", dismissDelay: 2.0)
            }
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.contentView.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func initCell(carModel: CarServiceModel) {
        model = carModel
        carName.text = model.name
        carRegdate.text = model.regdate
    }
}
