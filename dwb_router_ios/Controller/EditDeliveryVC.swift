//
//  EditDeliveryVC.swift
//  dwb_router_ios
//
//  Created by Aira on 8/16/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import DropDown
import CRNotifications

protocol EditDeliveryDialogDelegate {
    func onEditDeliveryDailog(model: CheckListModel)
}

class EditDeliveryVC: UIViewController {

    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var carLB: UILabel!
    @IBOutlet weak var contentUV: UIView!
    @IBOutlet weak var mainUV: UIView!
    @IBOutlet weak var contentUVHeight: NSLayoutConstraint!
    
    var model: CheckListModel = CheckListModel()
    let selectCar = DropDown()
    
    var selectedCarId = ""
    
    var addDeliveryUVArr: [AddDeliveryUV] = [AddDeliveryUV]()
    
    var delegate: EditDeliveryDialogDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainUV.setShadowToUIView(radius: 4.0, type: .MEDIUM)
        mainUV.clipsToBounds = true
        
        initUIView()
    }
    
    func initUIView() {
        for user in Utils.gUsers {
            if user.id == model.userid {
                nameLB.text = user.name
            }
        }
        
        selectCar.dismissMode = .onTap
        selectCar.direction = .bottom
        var carNames: [String] = [String]()
        var carIDs: [String] = [String]()
        for car in Utils.gCars {
            carNames.append(car.name)
            carIDs.append(car.id)
        }
        if !carIDs.contains(model.carid) {
            carLB.text = carNames[0]
        } else {
            for i in 0..<carNames.count {
                if carIDs[i] == model.carid {
                    carLB.text = carNames[i]
                }
            }
        }
        selectCar.dataSource = carNames
        selectCar.anchorView = carLB
        
        let regions: [String] = model.region.components(separatedBy: ",")
        let counts: [String] = model.amount.components(separatedBy: ",")
        
        var yPos: CGFloat = 0.0
        for region in Utils.gRegions {
            contentUV.layoutIfNeeded()
            let addRegionUV = Bundle.main.loadNibNamed("AddDeliveryUV", owner: self, options: nil)?.first as! AddDeliveryUV
            addRegionUV.initViewWithData(region: region)
            for i in 0..<regions.count {
                if region.title == regions[i] {
                    addRegionUV.setDeliveryCount(val: counts[i])
                    break
                } else {
                    addRegionUV.setDeliveryCount(val: "")
                    continue
                }
            }
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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onTapCarUB(_ sender: Any) {
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
    @IBAction func onTapYesUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        var regionName = ""
        var amount = ""
        var colorName = ""
        
        var index = 0
        for uiview in addDeliveryUVArr {
            if uiview.getDeliveryCount().isEmpty || uiview.getDeliveryCount() == "0" {
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
        
        model.region = regionName.substring(from: 1)
        model.amount = amount.substring(from: 1)
        model.color = colorName.substring(from: 1)
        model.carid = selectedCarId
        delegate?.onEditDeliveryDailog(model: model)
    }
}
