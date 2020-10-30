//
//  RoosterDetailVC.swift
//  dwb_router_ios
//
//  Created by Aira on 7/30/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import TangramKit
import MonthYearPicker
import Charts

class RoosterDetailVC: UIViewController {

    @IBOutlet weak var topUV: UIView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var calendarUIMG: UIImageView!
    
    var model: CheckListModel?
    var pieChartYPosition: CGFloat = 0.0
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateLB.text = model!.year + "-" + model!.numMonth
        FireManager.firebaseRef.getUserInfo(id: model!.userid, success: {(user) in
            self.nameLB.text = user.name
        })
        pieChartYPosition = initRegionsView()
        initData(monthYear: model!.year + "-" + model!.numMonth)
        
        let calendarGesture = UITapGestureRecognizer(target: self, action: #selector(onTapCalendarUIMG))
        calendarUIMG.addGestureRecognizer(calendarGesture)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initRegionsView() -> CGFloat {
        let topPosition = self.topUV.frame.origin.y + self.topUV.frame.height + 10.0
        
        let S = TGFloatLayout(.vert)
        S.tg_useFrame = true
        S.tg_height.equal(.wrap)
        S.tg_width.equal(self.view.frame.size.width)
        S.tg_top.equal(topPosition)
        S.tg_leadingPadding = 10.0
        S.tg_trailingPadding = 10.0
        S.tg_space = 10.0
        
        var paragrphCnt: Int = 0
        var labelTotalWidth: CGFloat = 10.0
        for region in Utils.gRegions {
            let label = UILabel()
            label.text = region.title
            label.tg_height.equal(24.0)
            let labelWidth: CGFloat = region.title.width(withConstrainedHeight: 24.0, font: .systemFont(ofSize: 14.0)) + 40.0
            labelTotalWidth += labelWidth + 10.0
            if labelTotalWidth > self.view.frame.size.width {
                paragrphCnt += 1
                labelTotalWidth = 10.0 + labelWidth
            }
            label.tg_width.equal(labelWidth)
            label.textAlignment = .center
            label.backgroundColor = UIColor.hexStringToUIColor(hex: region.color)
            label.setShadowToUIView(radius: 4.0, type: .SMALL)
            S.addSubview(label)
        }
        self.view.addSubview(S)
        let S_height = (24.0 + 10.0) * CGFloat(paragrphCnt + 1)
        return (topPosition + S_height)
    }
    
    func initData(monthYear: String) {
        var detailDatas: [CheckListModel] = [CheckListModel]()
        Utils.onShowProgressView(name: "Sever Connecting...")
        FireManager.firebaseRef.getDeleiveryUserMonthYear(userid: model!.userid, monthYear: monthYear, success: {(result) in
            Utils.onhideProgressView()
            detailDatas = result
            self.initPieChart(yPosition: self.pieChartYPosition, data: detailDatas)
            self.initScrollView(yPosition: self.pieChartYPosition, data: detailDatas)
        })
    }
    
    func initPieChart(yPosition: CGFloat, data: [CheckListModel]) {
        var regionShowModels: [RegionShowModel] = [RegionShowModel]()
        for region in Utils.gRegions {
            let regionShowModel: RegionShowModel = RegionShowModel()
            regionShowModel.regionModel = region
            regionShowModels.append(regionShowModel)
        }
        
        var totalDeliveryCount = 0
        for checkModel in data {
            let amountArr = checkModel.amount.split(separator: ",")
            let regionArr = checkModel.region.split(separator: ",")
            for i in 0..<amountArr.count {
                for regionShowModel in regionShowModels {
                    if regionShowModel.regionModel.title == regionArr[i] {
                        regionShowModel.delivery += (amountArr[i] as NSString).integerValue
                        totalDeliveryCount += (amountArr[i] as NSString).integerValue
                    }
                }
            }
        }
        
        let chartView: PieChartView = PieChartView(frame: CGRect(x: (self.view.frame.width - 300.0) / 2.0, y: yPosition, width: 300.0, height: 300.0))
        chartView.chartDescription?.enabled = false
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.usePercentValuesEnabled = true
        chartView.drawCenterTextEnabled = true
        
        let length = String(data.count).count
        let pargraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        pargraphStyle.lineBreakMode = .byTruncatingTail
        pargraphStyle.alignment = .center
        let centerText = NSMutableAttributedString(string: "\(data.count) Dagen\n\(totalDeliveryCount) Bestellingen")
        centerText.setAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, NSAttributedString.Key.paragraphStyle: pargraphStyle, NSAttributedString.Key.foregroundColor: UIColor.mainGreen()], range: NSRange(location: 0, length: centerText.length))
        centerText.addAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!], range: NSRange(location: 0, length: length + 5))
        centerText.addAttributes([NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!], range: NSRange(location: length + 7, length: centerText.length - length - 7))
        chartView.centerAttributedText = centerText
        chartView.legend.enabled = false
        chartView.entryLabelColor = .black
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
                
        var entries = [PieChartDataEntry]()
        
        for regionShow in regionShowModels {
            let entry = PieChartDataEntry(value: Double(regionShow.delivery), label: "\(regionShow.delivery)")
            entries.append(entry)
            
        }
        let set = PieChartDataSet(entries: entries, label: "Election Results")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        set.colors.removeAll()
        for regin in regionShowModels {
            set.colors.append(UIColor.hexStringToUIColor(hex: regin.regionModel.color))
        }
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.clear)
        
        chartView.data = data
        chartView.highlightValues(nil)
        self.view.addSubview(chartView)
    }
    
    func initScrollView(yPosition: CGFloat, data: [CheckListModel]) {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.mainBack()
        self.view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 12.0, y: yPosition + 310.0, width: self.view.frame.width - 24.0, height: self.view.frame.height - yPosition - 310.0)
        
        var posY: CGFloat = 0.0
        for model in data{
            var height: CGFloat = 0.0
            let deliveryDetailUV = Bundle.main.loadNibNamed("DeliveryDetailUV", owner: self, options: nil)?.first as! DeliveryDetailUV
            height = 2.0
            var heightCell = 25.0 * CGFloat(model.region.components(separatedBy: ",").count)
            if heightCell < 71.0 {
                heightCell = 71.0
            }
            height += heightCell
            height += 6.0

            posY += height

            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: posY)
            deliveryDetailUV.frame = CGRect(x: 0.0, y: posY - height, width: scrollView.frame.width, height: height - 4.0)
            deliveryDetailUV.backgroundColor = UIColor.mainRoosterRed()
            scrollView.addSubview(deliveryDetailUV)
            deliveryDetailUV.layoutIfNeeded()
            deliveryDetailUV.needsUpdateConstraints()

            let delta: CGFloat = (height - 4.0 - 25.0 * CGFloat(model.region.components(separatedBy: ",").count)) / 2.0
            
            deliveryDetailUV.initViewData(model: model, delta: delta)
            print("deliveryDetail: \(deliveryDetailUV.frame)")
        }
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
            self.initData(monthYear: self.dateLB.text!)
        }))
        self.present(alert,animated: true, completion: nil )
    }

    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

