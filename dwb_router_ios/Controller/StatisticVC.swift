//
//  StatisticVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
//import RKPieChart

class StatisticVC: UIViewController {
    
    @IBOutlet weak var workingdayLB: UILabel!
    
    let colors: [UIColor] = [UIColor.mainRoosterRed(), UIColor.mainRoosterBlue(), UIColor.mainRoosterGreen(), UIColor.mainRoosterYellow(), UIColor.mainRoosterPink()]
    
    var carTitle: String = ""
    var checkModels: [CheckListModel]?
    var strChartTitle: String = ""
    
    var car1WorkingDay: Int = 0
    var car2WorkingDay: Int = 0
    
    var westLandCnt: Int = 0
    var denHagCnt: Int = 0
    var schiVlaarCnt: Int = 0
    var delftCnt: Int = 0
    var rotterdamCnt: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        initUIView()
    }
    
    func initUIView() {
        self.title = carTitle
        
        initWorkingDay()
        initChart()
    }
    
    func initWorkingDay() {
        for model in checkModels! {
//            if model.regionServies[0].count > 0 && model.regionServies[0][0] != "" {
//                car1WorkingDay += 1
//            }
//            if model.regionServies[1].count > 0 && model.regionServies[1][0] != "" {
//                car2WorkingDay += 1
//            }
        }
        
        if self.title == "Car 1" {
            workingdayLB.text = carTitle + " has worked \(car1WorkingDay) days this month."
        } else if self.title == "Car 2" {
            workingdayLB.text = carTitle + " has worked \(car2WorkingDay) days this month."
        }
    }
    
    func initChart() {
//        if self.title == "Car 1" {
//            for model in checkModels! {
//                if model.regionServies[0].contains(AppConst.regions[1]) {
//                    westLandCnt += 1
//                }
//                if model.regionServies[0].contains(AppConst.regions[2]) {
//                    denHagCnt += 1
//                }
//                if model.regionServies[0].contains(AppConst.regions[3]) {
//                    delftCnt += 1
//                }
//                if model.regionServies[0].contains(AppConst.regions[4]) {
//                   schiVlaarCnt += 1
//                }
//                if model.regionServies[0].contains(AppConst.regions[5]) {
//                  rotterdamCnt += 1
//                }
//            }
//        } else if self.title == "Car 2" {
//            for model in checkModels! {
//                if model.regionServies[1].contains(AppConst.regions[1]) {
//                    westLandCnt += 1
//                }
//                if model.regionServies[1].contains(AppConst.regions[2]) {
//                    denHagCnt += 1
//                }
//                if model.regionServies[1].contains(AppConst.regions[3]) {
//                    delftCnt += 1
//                }
//                if model.regionServies[1].contains(AppConst.regions[4]) {
//                   schiVlaarCnt += 1
//                }
//                if model.regionServies[1].contains(AppConst.regions[5]) {
//                  rotterdamCnt += 1
//                }
//            }
//        }
//        
//        
//        let firstItem: RKPieChartItem = RKPieChartItem(ratio: uint(westLandCnt), color: colors[0], title: AppConst.regions[1] + ": \(westLandCnt)")
//        let secondItem: RKPieChartItem = RKPieChartItem(ratio: uint(denHagCnt), color: colors[1], title: AppConst.regions[2] + ": \(denHagCnt)")
//        let thirdItem: RKPieChartItem = RKPieChartItem(ratio: uint(delftCnt), color: colors[2], title: AppConst.regions[3] + ": \(delftCnt)")
//        let forthItem: RKPieChartItem = RKPieChartItem(ratio: uint(schiVlaarCnt), color: colors[3], title: AppConst.regions[4] + "\(schiVlaarCnt)")
//        let fifthItem: RKPieChartItem = RKPieChartItem(ratio: uint(rotterdamCnt), color: colors[4], title: AppConst.regions[5] + ": \(rotterdamCnt)")
//        
//        let chartView = RKPieChartView(items: [firstItem, secondItem, thirdItem, forthItem, fifthItem], centerTitle: strChartTitle)
//        chartView.circleColor = .clear
//        chartView.translatesAutoresizingMaskIntoConstraints = false
//        chartView.arcWidth = 60
//        chartView.isIntensityActivated = false
//        chartView.style = .butt
//        chartView.isTitleViewHidden = false
//        chartView.isAnimationActivated = true
//        self.view.addSubview(chartView)
//        
//        chartView.widthAnchor.constraint(equalToConstant: 300).isActive = true
//        chartView.heightAnchor.constraint(equalToConstant: 300).isActive = true
//        chartView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        chartView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
    }

    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
