//
//  AddDeliveryVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/30/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import DropDown
import CRNotifications
import SwiftyJSON

protocol AddDeliveryDialogDelegate {
    func onAddDeliveryDailog(model: CheckListModel)
}

class AddDeliveryVC: UIViewController {

    @IBOutlet weak var mainUV: UIView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var nameUB: UIButton!
    @IBOutlet weak var carLB: UILabel!
    @IBOutlet weak var carUB: UIButton!
    @IBOutlet weak var contentUV: UIView!
    @IBOutlet weak var contentUVHeight: NSLayoutConstraint!
    
    let selectUser = DropDown()
    let selectCar = DropDown()
    
    var selectedUserId = ""
    var selectedCarId = ""
    
    var addDeliveryUVArr: [AddDeliveryUV] = [AddDeliveryUV]()
    
    var delegate: AddDeliveryDialogDelegate?
    
    var allOrders: [OrderModel] = [OrderModel]()
    
    var date:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainUV.setShadowToUIView(radius: 4.0, type: .MEDIUM)
        mainUV.clipsToBounds = true
        
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
        selectUser.dismissMode = .onTap
        selectUser.direction = .bottom
        var userNames: [String] = [String]()
        for user in Utils.gUsers {
            userNames.append(user.name)
        }
        selectUser.dataSource = userNames
        selectUser.anchorView = nameLB
        nameLB.text = userNames[0]
        selectedUserId = Utils.gUsers[0].id
        
        selectCar.dismissMode = .onTap
        selectCar.direction = .bottom
        var carNames: [String] = [String]()
        for car in Utils.gCars {
            carNames.append(car.name)
        }
        selectCar.dataSource = carNames
        selectCar.anchorView = carLB
        carLB.text = carNames[0]
        selectedCarId = Utils.gCars[0].id
        
        var yPos: CGFloat = 0.0
        for region in Utils.gRegions {
            contentUV.layoutIfNeeded()
            let addRegionUV = Bundle.main.loadNibNamed("AddDeliveryUV", owner: self, options: nil)?.first as! AddDeliveryUV
            addRegionUV.initViewWithData(region: region)
            addRegionUV.translatesAutoresizingMaskIntoConstraints = false
            contentUV.addSubview(addRegionUV)
            NSLayoutConstraint.activate([
                addRegionUV.centerXAnchor.constraint(equalTo: contentUV.centerXAnchor),
                addRegionUV.topAnchor.constraint(equalTo: contentUV.topAnchor, constant: yPos),
                addRegionUV.widthAnchor.constraint(equalToConstant: contentUV.frame.width),
                addRegionUV.heightAnchor.constraint(equalToConstant: 30.0)
            ])
            addDeliveryUVArr.append(addRegionUV)
            yPos += 30.0
        }
        contentUV.autoresizesSubviews = true
        contentUVHeight.constant = 30.0 * CGFloat(Utils.gRegions.count)
        contentUV.needsUpdateConstraints()
        
        Utils.onShowProgressView(name: "Server Connection...")

        let params = [
            "token": APIManager.token
        ]

        var regions: [String] = [String]()

        for region in Utils.gRegions {
            regions.append(region.title)
        }

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
            self.onGetFilter(regions: regions, date: self.date)
        })
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
        
        for i in 0..<Utils.gRegions.count {
            var count: Int = 0
            for order in Utils.gOrders {
                if Utils.gRegions[i].title == order.shippingPerson.region {
                    count += 1
                }
            }
            addDeliveryUVArr[i].setDeliveryCount(val: "\(count)")
        }
    }
    
    @IBAction func onTapAddUserUB(_ sender: Any) {
        selectUser.topOffset = CGPoint(x: 0, y: (selectUser.anchorView?.plainView.bounds.height)!)
        selectUser.show()
        selectUser.selectionAction = {[unowned self] (index: Int, item: String) in
            self.nameLB.text = item
            self.selectedUserId = Utils.gUsers[index].id
        }
    }
    
    @IBAction func onTapAddCarUB(_ sender: Any) {
        selectCar.topOffset = CGPoint(x: 0, y: (selectCar.anchorView?.plainView.bounds.height)!)
        selectCar.show()
        selectCar.selectionAction = {[unowned self] (index: Int, item: String) in
            self.carLB.text = item
            self.selectedCarId = Utils.gCars[index].id
        }
    }
    
    @IBAction func onTapCancelUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapOKUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        var regionName = ""
        var amount = ""
        var colorName = ""
        
        var index = 0
        for uiview in addDeliveryUVArr {
            if !uiview.getCheckedState() || uiview.getDeliveryCount().isEmpty || uiview.getDeliveryCount() == "0" {
                continue
            }
            regionName += "," + uiview.getRegionTitle()
            amount += "," + uiview.getDeliveryCount()
            colorName += "," + Utils.gRegions[index].color
            index += 1
        }
        
        if regionName.count == 0 {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Voer een waarde van de regio in.", dismissDelay: 2.0)
            return
        }
        
        let deliveryModel: CheckListModel = CheckListModel()
        deliveryModel.region = regionName.substring(from: 1)
        deliveryModel.amount = amount.substring(from: 1)
        deliveryModel.color = colorName.substring(from: 1)
        deliveryModel.carid = selectedCarId
        deliveryModel.userid = selectedUserId
        delegate?.onAddDeliveryDailog(model: deliveryModel)
    }
}
