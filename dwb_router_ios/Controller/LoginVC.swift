//
//  LoginVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import FirebaseAuth
import Toast_Swift
import CRNotifications

class LoginVC: UIViewController {

    @IBOutlet weak var phoneUV: UIView!
    @IBOutlet weak var codeUV: UIView!
    @IBOutlet weak var loginUB: UIButton!
    @IBOutlet weak var verifyUB: UIButton!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    
    var isVerify = false
    var strVerificaitonID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUIView()
        currentAuthCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initUIView() {
        phoneUV.setRadius(color: UIColor.mainBlack(), width: 1.0, radius: 8.0)
        codeUV.setRadius(color: UIColor.mainBlack(), width: 1.0, radius: 8.0)
        loginUB.setShadowToUIView(radius: 8.0, type: .MEDIUM)
        verifyUB.setRadius(color: UIColor.mainBlack(), width: 0.0, radius: 8.0)
    }
    
    func currentAuthCheck() {
        if Auth.auth().currentUser == nil {
            return
        } else {
            Utils.onShowProgressView(name: "Loading...")
            let userId = Auth.auth().currentUser?.uid
            FireManager.firebaseRef.getUserInfo(id: userId!, success: {(user) in
                Utils.gUser = user
                if user.name.isEmpty || user.name == "" {
                    Utils.onhideProgressView()
                    CRNotifications.showNotification(type: CRNotifications.info, title: "info", message: "Wachten op managerovereenkomst.", dismissDelay: 2.0)
                    return
                }
                FireManager.firebaseRef.getAllUsers(success: {(users) in
                    Utils.gUsers = users
                    Utils.onhideProgressView()
                    self.performSegue(withIdentifier: "goToMain", sender: nil)
                })
            })
        }
    }

    @IBAction func onTapVerifyUB(_ sender: Any) {
        var phoneNumber = phoneTF.text!
        if phoneNumber == "2096227257" {
            phoneNumber = "+856" + phoneNumber
        } else {
            phoneNumber = "+31" + phoneNumber
        }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.view.makeToast(error.localizedDescription)
                return
            }
            self.strVerificaitonID = verificationID!
            self.isVerify = true
        }
    }
    
    
    @IBAction func onTapLoginUB(_ sender: Any) {
        if !isVerify {
            return
        } else {
            Utils.onShowProgressView(name: "Loading...")
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.strVerificaitonID, verificationCode: codeTF.text!)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    Utils.onhideProgressView()
                    self.view.makeToast(error.localizedDescription)
                    return
                }
                let userID = user?.user.uid
                
                if Utils.gUser == nil {
                    FireManager.firebaseRef.addUser(phone: (user?.user.phoneNumber)!, id: userID!, success: {(result) in
                        Utils.onhideProgressView()
                        if result == "success" {
                            CRNotifications.showNotification(type: CRNotifications.info, title: "info", message: "Wachten op managerovereenkomst.", dismissDelay: 2.0)
                        } else {
                            CRNotifications.showNotification(type: CRNotifications.error, title: "Error", message: "Kan gebruikersgegevens niet toevoegen", dismissDelay: 2.0)
                        }
                        return
                    })
                } else {
                    FireManager.firebaseRef.getUserInfo(id: userID!, success: {(user) in
                        Utils.gUser = user
                        if user.name == "" || user.name.isEmpty {
                            Utils.onhideProgressView()
                            CRNotifications.showNotification(type: CRNotifications.info, title: "info", message: "Wachten op managerovereenkomst.", dismissDelay: 2.0)
                            return
                        } else {
                            FireManager.firebaseRef.getAllUsers(success: {(users) in
                                Utils.gUsers = users
                                Utils.onhideProgressView()
                                self.performSegue(withIdentifier: "goToMain", sender: nil)
                            })
                        }
                    })
                }
            }
        }
    }
}
