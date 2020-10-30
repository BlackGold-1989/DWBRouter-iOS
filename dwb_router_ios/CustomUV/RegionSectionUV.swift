//
//  RegionSectionUV.swift
//  dwb_router_ios
//
//  Created by Aira on 7/26/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications
import CULColorPicker

class RegionSectionUV: UICollectionReusableView {
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var removeUIMG: UIImageView!
    @IBOutlet weak var addUIMG: UIImageView!
    @IBOutlet weak var editUIMG: UIImageView!
    
    var model: RegionModel = RegionModel()
    
    override func awakeFromNib() {
        let tapRemove = UITapGestureRecognizer(target: self, action: #selector(onTapRemoveUIMG))
        removeUIMG.addGestureRecognizer(tapRemove)
        
        let tapEdit = UITapGestureRecognizer(target: self, action: #selector(onTapEditUIMG))
        editUIMG.addGestureRecognizer(tapEdit)
        
        let tapAdd = UITapGestureRecognizer(target: self, action: #selector(onTapAddUIMG))
        addUIMG.addGestureRecognizer(tapAdd)
    }
    
    func initHeader(regionModel: RegionModel) {
        model = regionModel
        titleLB.text = "\(model.title) (\(model.postal.count))"
        self.backgroundColor = UIColor.hexStringToUIColor(hex: model.color)
    }
    
    @objc func onTapRemoveUIMG() {
        FireManager.firebaseRef.removeRegion(model: model, success: {(result) in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes voor verwijder regio", dismissDelay: 2.0)
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan regio niet verwijderen.", dismissDelay: 2.0)
            }
        })
    }
    
    @objc func onTapEditUIMG() {
        let alert = UIAlertController(title: "", message: "verwerking voor het bijwerken van gebied.", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.borderStyle = .roundedRect
            textField.text = self.model.title
        }
        
        let colorPicker = ColorPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        
        alert.view.addSubview(colorPicker)
        NSLayoutConstraint.activate([
            colorPicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            colorPicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 140.0),
            colorPicker.widthAnchor.constraint(equalToConstant: 200),
            colorPicker.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -60),
            colorPicker.heightAnchor.constraint(equalToConstant: 200)
        ])

        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned alert] _ in
            let textField = alert.textFields![0]
            if textField.text!.count > 0 {
                let newModel: RegionModel = RegionModel()
                newModel.title = textField.text!
                newModel.color = colorPicker.selectedColor.hexString(.AARRGGBB)
                newModel.postal = self.model.postal
                FireManager.firebaseRef.removeRegion(model: self.model, success: {(result) in
                    if result == "success" {
                        FireManager.firebaseRef.addRegion(model: newModel, success: {(result) in
                            if result == "success" {
                                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Regio voor geslaagde update.", dismissDelay: 2.0)
                            } else {
                                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan regio niet bewerken.", dismissDelay: 2.0)
                            }
                        })
                    }
                })
            } else {
                CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Voer de naam van de auto in.", dismissDelay: 2.0)
            }
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func onTapAddUIMG() {
        let alert = UIAlertController(title: "", message: "Voer de postcode in.", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.borderStyle = .roundedRect
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned alert] _ in
            let textField = alert.textFields![0]
            if textField.text!.count > 0 {
                if self.model.postal.contains(textField.text!) {
                    CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Deze postcode bestaat al.", dismissDelay: 2.0)
                } else {
                    self.model.postal.append(textField.text!)
                    FireManager.firebaseRef.addRegion(model: self.model, success: {(result) in
                        if result == "success" {
                            CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes voor het toevoegen van postcode.", dismissDelay: 2.0)
                        } else {
                            CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan postcode niet toevoegen.", dismissDelay: 2.0)
                        }
                    })
                }
            } else {
                CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Voer de naam van de auto in.", dismissDelay: 2.0)
            }
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
