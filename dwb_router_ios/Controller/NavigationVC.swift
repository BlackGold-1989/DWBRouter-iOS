//
//  NavigationVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import WebKit

class NavigationVC: UIViewController {
    @IBOutlet weak var webUV: WKWebView!
    
//    var model: OrderModel?
    var index: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let url = "https://www.google.com/maps/dir/?api=1&destination=\(Utils.gAllLatLang[index! + 1].latitude), \(Utils.gAllLatLang[index! + 1].longitude)&origin=\(Utils.gAllLatLang[index!].latitude),\(Utils.gAllLatLang[index!].longitude)&travelmode=driving&dir_action=navigate"
        if let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedURL) {
              webUV.load(URLRequest(url: url))
        }
        
        self.webUV.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" {
            if webUV.isLoading {
                Utils.onShowProgressView(name: "Loading...")
            } else {
                Utils.onhideProgressView()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapDoneUB(_ sender: Any) {
        let name = Utils.gUser!.name
        if name.count == 0 {
            self.view.makeToast("de naam is leeg.")
            return
        }
        
        Utils.gProcessing[index!] = "Done"
        
        let strDate = Utils.covertDateToString(dateFormat: "yyyy-MM-dd", date: Date())
        Utils.onShowProgressView(name: "Please wait...")
        
        FireManager.firebaseRef.getHistoryInfo(date: strDate, success: {(models) in
            Utils.onhideProgressView()
            var isContainRegion = false
            var isNewAdd = true
            var updatedModel: HistoryModel = HistoryModel()
            for model in models {
                if model.id == Utils.gUser!.id {
                    isNewAdd = false
                    updatedModel = model
                    for region in model.regions {
                        if region == Utils.gSelOrders[self.index!].shippingPerson.region {
                            isContainRegion = true
                        }
                    }
                    break
                }
            }
            
            if isNewAdd {
                let historyModel: HistoryModel = HistoryModel()
                historyModel.id = Utils.gUser!.id
                historyModel.name = Utils.gUser!.name
                historyModel.count = 1
                historyModel.date = strDate
                historyModel.regions.append(Utils.gSelOrders[self.index!].shippingPerson.region)
                FireManager.firebaseRef.setHistoryInfo(model: historyModel, success: {(result) in
                    if result == "success" {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.view.makeToast("Failed...")
                    }
                })
            } else {
                if !isContainRegion {
                    updatedModel.regions.append(Utils.gSelOrders[self.index!].shippingPerson.region)
                }
                updatedModel.count += 1
                FireManager.firebaseRef.updateHistoryInfo(model: updatedModel, success: {(result) in
                    if result == "success" {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.view.makeToast("Failed...")
                    }
                })
            }
        })
    }
}



