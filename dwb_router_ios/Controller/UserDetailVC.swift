//
//  UserDetailVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/25/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import DropDown
import CRNotifications

class UserDetailVC: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var typeUB: UIButton!
    @IBOutlet weak var regdateTF: UITextField!
    @IBOutlet weak var saveUB: UIButton!
    
    var userInfo: UserModel = UserModel()
    
    let selectUserType = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initNavigationBar()
        initUIView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initNavigationBar() {
        self.navigationItem.title = "Bewerk gebruiker"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(onTapBackUB))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.mainBlack()
    }
    
    func initUIView() {
        phoneTF.isEnabled = false
        typeTF.isEnabled = false
        regdateTF.isEnabled = false
        
        nameTF.text = userInfo.name
        phoneTF.text = userInfo.phone
        addressTF.text = userInfo.address
        typeTF.text = userInfo.type
        regdateTF.text = userInfo.regdate
        
        saveUB.setShadowToUIView(radius: saveUB.frame.height / 2.0, type: .MEDIUM)
        
        selectUserType.dismissMode = .onTap
        selectUserType.direction = .top
        selectUserType.dataSource = ["owner", "driver"]
        selectUserType.anchorView = typeUB
    }
    
    @objc func onTapBackUB() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapSaveUB(_ sender: Any) {
        if nameTF.text!.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Vul alstublieft uw naam in.", dismissDelay: 2.0)
            return
        }
        if addressTF.text!.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Vul alstublieft uw adres in.", dismissDelay: 2.0)
            return
        }
        
        userInfo.name = nameTF.text!
        userInfo.address = addressTF.text!
        userInfo.type = typeTF.text!
        
        FireManager.firebaseRef.editUser(model: userInfo, success: {result in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Gebruiker bewerken.", dismissDelay: 2.0)
                self.onTapBackUB()
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan gebruiker niet bewerken.", dismissDelay: 2.0)
            }
        })
    }
    
    @IBAction func onTapTypeUB(_ sender: Any) {
        selectUserType.topOffset = CGPoint(x: 0, y: -(selectUserType.anchorView?.plainView.bounds.height)!)
        selectUserType.show()
        selectUserType.selectionAction = {[unowned self] (index: Int, item: String) in
            self.typeTF.text = item
        }
    }
}
