//
//  ManagerVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/25/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import IMSegmentPageView
import CRNotifications
import CULColorPicker

class ManagerVC: UIViewController {
    
    @IBOutlet weak var addUB: UIButton!
    
    var titleView: IMSegmentTitleView?
    var pageView: IMPageContentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let property = IMSegmentTitleProperty()
        property.indicatorHeight = 1
        property.indicatorType = .width
        property.indicatorColor = UIColor.black
        property.indicatorExtension = self.view.frame.width / 3.0
        property.isLeft = false
        property.showBottomLine = false
        property.titleNormalColor = UIColor.mainLightGrey()
        property.titleSelectColor = UIColor.mainBlack()
        
        let titleViewYPosition: CGFloat = (self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) + (self.navigationController?.navigationBar.frame.height ?? 0.0)
                
        let titles = ["CAR", "USER", "REGION"]
        let titleFrame = CGRect(x: 0.0, y: titleViewYPosition + 45.0, width: self.view.frame.width, height: 45.0)
        titleView = IMSegmentTitleView(frame: titleFrame, titles: titles, property: property)
        titleView!.backgroundColor = UIColor.mainBack()
        titleView!.delegate = self
        self.view.addSubview(titleView!)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: "CarManagerVC") as! CarManagerVC
        let vc2 = storyboard.instantiateViewController(withIdentifier: "UserManagerVC") as! UserManagerVC
        let vc3 = storyboard.instantiateViewController(withIdentifier: "RegionManagerVC") as! RegionManagerVC
        let childVCs: [UIViewController] = [vc1, vc2, vc3] // viewControllers
        let contentFrame = CGRect(x: 0.0, y: titleViewYPosition + 90.0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 90.0)
        
        vc1.preferredContentSize = contentFrame.size
        vc2.preferredContentSize = contentFrame.size
        vc3.preferredContentSize = contentFrame.size
        
        pageView = IMPageContentView(Frame: contentFrame, childVCs: childVCs, parentVC: self)
        pageView!.delegate = self
        self.view.addSubview(pageView!)
        
        addUB.setShadowToUIView(radius: addUB.frame.height / 2.0, type: .MEDIUM)
        self.view.bringSubviewToFront(addUB)
    }
    
    @IBAction func onTapAddUB(_ sender: Any) {
        if titleView?.selectIndex == 0 {
            let alert = UIAlertController(title: "", message: "voer het auto nummer in.", preferredStyle: .alert)
            alert.addTextField { (textField) -> Void in
                textField.borderStyle = .roundedRect
            }
            
            let okAction = UIAlertAction(title: "OK", style: .default) { [unowned alert] _ in
                let textField = alert.textFields![0]
                if textField.text!.count > 0 {
                    let carModel: CarServiceModel = CarServiceModel()
                    carModel.name = textField.text!
                    FireManager.firebaseRef.addCar(model: carModel, success: {(result) in
                        if result == "success" {
                            CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes met het toevoegen van auto.", dismissDelay: 2.0)
                        } else {
                            CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Auto toevoegen mislukt.", dismissDelay: 2.0)
                        }
                    })
                } else {
                    CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Voer de naam van de auto in.", dismissDelay: 2.0)
                }
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "", message: "Verwerking voor het toevoegen van gebied.", preferredStyle: .alert)
            alert.addTextField { (textField) -> Void in
                textField.borderStyle = .roundedRect
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
                    newModel.postal = [String]()
                    FireManager.firebaseRef.addRegion(model: newModel, success: {(result) in
                        if result == "success" {
                            CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes toevoegen regio.", dismissDelay: 2.0)
                        } else {
                            CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan regio niet toevoegen.", dismissDelay: 2.0)
                        }
                    })
                } else {
                    CRNotifications.showNotification(type: CRNotifications.info, title: "Info", message: "Voer de naam van de auto in.", dismissDelay: 2.0)
                }
            }
            let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ManagerVC: IMSegmentTitleViewDelegate {
    func segmentTitleView(_ titleView: IMSegmentTitleView, startIndex: Int, endIndex: Int) {
        pageView?.contentViewCurrentIndex = endIndex
        if endIndex == 1 {
            self.addUB.isHidden = true
        } else {
            self.addUB.isHidden = false
        }
    }
}

extension ManagerVC: IMPageContentDelegate {
    func contentViewDidScroll(_ contentView: IMPageContentView, startIndex: Int, endIndex: Int, progress: CGFloat) {
        //
    }
    
    func contenViewDidEndDecelerating(_ contentView: IMPageContentView, startIndex: Int, endIndex: Int) {
        titleView?.selectIndex = endIndex
        if endIndex == 1 {
            self.addUB.isHidden = true
        } else {
            self.addUB.isHidden = false
        }
    }
    
    
}
