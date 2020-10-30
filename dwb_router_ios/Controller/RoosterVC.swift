//
//  RoosterVC.swift
//  dwb_router_ios
//
//  Created by Aira on 6/21/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import MonthYearPicker
import CRNotifications

class RoosterVC: UIViewController {

    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var calendarUIMG: UIImageView!
    @IBOutlet weak var roosterUSV: UIScrollView!
    
    var checkModels: [CheckListModel] = [CheckListModel]()
    var checkModelsByDateUser: [[CheckListModel]] = [[CheckListModel]]()
    var heightUSV: CGFloat = 0
    var dateArray: String = ""
    var loadCellIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUIView()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goRoosterDetail" {
            let destinationVC = segue.destination as! RoosterDetailVC
            destinationVC.model = sender as? CheckListModel
        }
    }
    
    func initUIView() {
        let calendarGesture = UITapGestureRecognizer(target: self, action: #selector(onTapCalendarUIMG))
        calendarUIMG.addGestureRecognizer(calendarGesture)
        
        dateLB.text = Utils.covertDateToString(dateFormat: "yyyy-MM", date: Date())
        dateArray = dateLB.text! + "-01"
        initData(dateStr: dateArray)
    }
    
    @objc func onTapCalendarUIMG() {
        let alert = UIAlertController(title: "Select Month", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        let picker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width: 250, height: 140)))
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.dateLB.text = Utils.covertDateToString(dateFormat: "yyyy-MM", date: picker.date)
            self.dateArray = self.dateLB.text! + "-01"
            self.initData(dateStr: self.dateArray)
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    
    
    func initData(dateStr: String) {
        checkModels.removeAll()
        let index: Int = 0
        var shownDate = dateStr
        while true {
            if !shownDate.contains(self.dateLB.text!) {
                break
            }
            
            let checkModel: CheckListModel = CheckListModel()
            
            var date = Utils.convertStringToDate(dateFormat: "yyyy-MM-dd", date: shownDate)

            checkModel.id = "\(index)"
            checkModel.day = Utils.covertDateToString(dateFormat: "dd", date: date)
            checkModel.month = Utils.covertDateToString(dateFormat: "MMM", date: date)
            checkModel.numMonth = Utils.covertDateToString(dateFormat: "MM", date: date)
            checkModel.week = Utils.covertDateToString(dateFormat: "EEE", date: date)
            checkModel.year = Utils.covertDateToString(dateFormat: "yyyy", date: date)
            
            self.checkModels.append(checkModel)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            shownDate = Utils.covertDateToString(dateFormat: "yyyy-MM-dd", date: date)
        }
        Utils.onShowProgressView(name: "Sever Connecting...")
        FireManager.firebaseRef.getDeliveryByMonth(yearMonth: dateLB.text!, result: {(checkArr) in
            Utils.onhideProgressView()
            self.checkModelsByDateUser.removeAll()
            if checkArr.isEmpty {
                for checkModel in self.checkModels {
                    var checkModelByDay = [CheckListModel]()
                    checkModelByDay.append(checkModel)
                    self.checkModelsByDateUser.append(checkModelByDay)
                }
            } else {
                for checkModel in self.checkModels {
                    var checkModelByDay = [CheckListModel]()
                    for model in checkArr {
                        if checkModel.day == model.day {
                            if !checkModelByDay.isEmpty && checkModelByDay.last!.region == "" {
                                checkModelByDay.removeLast()
                            }
                            checkModelByDay.append(model)
                        } else {
                            if checkModelByDay.isEmpty {
                                checkModelByDay.append(checkModel)
                            }
                        }
                    }
                    self.checkModelsByDateUser.append(checkModelByDay)
                }
            }
            self.loadCellWithData(data: self.checkModelsByDateUser)
        })
    }
    
    func loadCellWithData(data: [[CheckListModel]]) {
        var posY: CGFloat = 0.0
        for modelList in data {
            var height: CGFloat = 0.0
            let roosterCellUV = Bundle.main.loadNibNamed("RoosterCell", owner: self, options: nil)?.first as! RoosterCell
                        
            if modelList[0].region == "" {
                height += 75.0
            } else {
                height = 7.0
                for model in modelList {
                    var heightCell = 25.0 * CGFloat(model.region.components(separatedBy: ",").count)
                    if (heightCell < 62.0) {
                        heightCell = 62.0
                    }
                    
                    height += heightCell
                    height += 6.0
                    if modelList.count > 1 && model == modelList.last{
                        height += 2.0 * CGFloat(modelList.count - 1)
                    }
                }
            }
            posY += height
            
            roosterUSV.contentSize = CGSize(width: roosterUSV.frame.width, height: posY)
            roosterCellUV.frame = CGRect(x: 0.0, y: posY - height, width: roosterUSV.frame.width, height: height)
            roosterUSV.addSubview(roosterCellUV)
            roosterCellUV.delegate = self
            
            roosterCellUV.layoutIfNeeded()
            roosterCellUV.translatesAutoresizingMaskIntoConstraints = true
            
            roosterCellUV.initCell(models: modelList)
                 
        }
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RoosterVC: RoosterCellDelegate {
    func onRoosterCellDelegate(model: CheckListModel) {
        FireManager.firebaseRef.addDelivery(model: model, success: {(result) in
            if result == "success" {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Success", message: "Succes voor het toevoegen van geschiedenis.", dismissDelay: 2.0)
                self.initData(dateStr: self.dateLB.text! + "-01")
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Failed", message: "Kan geschiedenis niet toevoegen.", dismissDelay: 2.0)
            }
        })
    }
    
    func onRemoveHistoryDelegate() {
        self.initData(dateStr: self.dateLB.text! + "-01")
    }
    
    func onGoRoosterDetailDelegate(model: CheckListModel) {
        self.performSegue(withIdentifier: "goRoosterDetail", sender: model)
    }
    
    func onEditHistoryDelegate() {
        self.initData(dateStr: self.dateLB.text! + "-01")
    }
}


