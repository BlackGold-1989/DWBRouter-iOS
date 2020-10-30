//
//  UserCell.swift
//  dwb_router_ios
//
//  Created by Aira on 7/25/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications

protocol UserCellDelegate {
    func didSelectEditDelegate(model: UserModel)
}

class UserCell: UITableViewCell {

    @IBOutlet weak var containUV: UIView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var phoneLB: UILabel!
    @IBOutlet weak var regdateLB: UILabel!
    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var removeUIMG: UIImageView!
    @IBOutlet weak var editUIMG: UIImageView!
    
    var model: UserModel = UserModel()
    
    var delegate: UserCellDelegate?
    
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
        FireManager.firebaseRef.removeUser(model: self.model, success: {(result) in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes gebruiker verwijderen", dismissDelay: 2.0)
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan gebruiker niet verwijderen", dismissDelay: 2.0)
            }
        })
    }
    
    @objc func onTapEditUIMG() {
        delegate?.didSelectEditDelegate(model: self.model)
    }
    
    func initCell(userModel: UserModel) {
        self.model = userModel
        nameLB.text = model.name.count == 0 ? "New User" : model.name
        regdateLB.text = model.regdate
        typeLB.text = model.type.count == 0 ? "DRIVER" : model.type.uppercased()
        phoneLB.text = model.phone
    }

}
