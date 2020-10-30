//
//  FilterVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import SwiftyJSON

class FilterVC: UIViewController {

    @IBOutlet weak var contentUV: UIView!
    @IBOutlet weak var calendarUIMG: UIImageView!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var filterUB: UIButton!
    @IBOutlet weak var containerUVHeight: NSLayoutConstraint!
    @IBOutlet weak var containerUV: UIView!
    
    var regionModels: [RegionModel] = [RegionModel]()
    var allOrders: [OrderModel] = [OrderModel]()
    
    let colors: [UIColor] = [UIColor.mainRoosterRed(), UIColor.mainRoosterBlue(), UIColor.mainRoosterGreen(), UIColor.mainRoosterYellow(), UIColor.mainRoosterPink()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func initUIView() {
        contentUV.setShadowToUIView(radius: 4.0, type: .MEDIUM)
        filterUB.layer.cornerRadius = 8.0
        
        let date = Date()
        dateLB.text = Utils.covertDateToString(dateFormat: "dd-MM-yyyy", date: date)
                
        let calendarGesture = UITapGestureRecognizer(target: self, action: #selector(onTapCalendar))
        calendarUIMG.addGestureRecognizer(calendarGesture)
//        for i in 1..<AppConst.regions.count {
        for i in 0..<Utils.gRegions.count {
            var regionModel: RegionModel = RegionModel()
            regionModel = Utils.gRegions[i]
            regionModel.id = "\(i)"
            regionModel.isCheck = false
            regionModels.append(regionModel)
        }
        
        for i in 0..<regionModels.count{
           containerUV.layoutIfNeeded()
           let cateUV = Bundle.main.loadNibNamed("CheckBoxUV", owner: self, options: nil)?.first as! CheckBoxUV
//            cateUV.initWithRegionModel(model: regionModels[i], color: colors[i])
            cateUV.initWithRegionModel(model: regionModels[i], color: UIColor.hexStringToUIColor(hex: regionModels[i].color))
            cateUV.translatesAutoresizingMaskIntoConstraints = false
            containerUV.addSubview(cateUV)
            NSLayoutConstraint.activate([
                cateUV.centerXAnchor.constraint(equalTo: containerUV.centerXAnchor),
                cateUV.topAnchor.constraint(equalTo: containerUV.topAnchor, constant: (CGFloat)(i * 44)),
                cateUV.widthAnchor.constraint(equalToConstant: containerUV.frame.width),
                cateUV.heightAnchor.constraint(equalToConstant: 44.0)
            ])
        }
        containerUV.autoresizesSubviews = true
        containerUVHeight.constant = (CGFloat)(44 * (regionModels.count))
        containerUV.needsUpdateConstraints()
        
    }

    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapFilterUB(_ sender: Any) {
        var regions: [String] = [String]()
        
        for model in regionModels {
            if model.isCheck {
                regions.append(model.title)
            }
        }
        
        Utils.onShowProgressView(name: "Server Connection...")
        
        let params = [
            "token": APIManager.token
        ]
        
        APIManager.apiConnection(param: params, url: APIManager.API_GET_ORDER, method: .get, success: {(json) in
            Utils.onhideProgressView()
            var jsonArr: [JSON] = [JSON]()
            if json["items"].arrayValue.count > 0 {
                jsonArr = json["items"].arrayValue
                self.allOrders.removeAll()
                for i in 0..<jsonArr.count {
                    var object: JSON = JSON()
                    object = jsonArr[i]
                    if object.dictionaryObject != nil {
                        let orderModel = OrderModel()
                        orderModel.initWithJSON(data: object)
                        self.allOrders.append(orderModel)
                    }
                }
            } else {
                self.view.makeToast("There is no data...")
            }
            print(self.allOrders.count)
            self.onGetFilter(regions: regions, date: self.dateLB.text!)
        })
    }
    
    
    @objc func onTapCalendar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        vc.delegate = self
        self.navigationController?.present(vc, animated: false, completion: nil)
    }
    
    func onGetFilter(regions: [String], date: String) {
        Utils.gOrders.removeAll()
        
        for order in allOrders {
            if regions.count > 0 {
                for region in regions {
                    if Utils.isSameDate(date1: date, date2: order.deliveryDate)  {
                        if order.shippingPerson.region == region {
                            if !Utils.gOrders.contains(order) {
                                Utils.gOrders.append(order)
                            }
                        }
                    }
                }
            } else {
                if Utils.isSameDate(date1: date, date2: order.deliveryDate) {
                    order.deliveryDate = date
                    Utils.gOrders.append(order)
                }
            }
        }
        self.performSegue(withIdentifier: "goToOrder", sender: nil)
    }
}

extension FilterVC: DatePickerVCDelegate {
    func selectedDate(strDate: String) {
        self.dateLB.text = strDate
    }
}
