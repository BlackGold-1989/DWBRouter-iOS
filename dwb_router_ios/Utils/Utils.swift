//
//  Utils.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import SVProgressHUD
import CoreLocation
import PDFKit

class Utils {
    static var gUser: UserModel?
    static var gRoosterCellMap = [String: [CheckListModel]]()
    static var gUsers: [UserModel] = [UserModel]()
    static var gCars: [CarServiceModel] = [CarServiceModel]()
    static var gRegions: [RegionModel] = [RegionModel]()
    static var gOrders: [OrderModel] = [OrderModel]()
    static var gSelOrders: [OrderModel] = [OrderModel]()
    static var gProcessing: [String] = [String]()
    static var gAllRouters: [RouterInfoModel] = [RouterInfoModel]()
    static var gAllLatLang: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    
    static func onShowProgressView (name: String) {
        SVProgressHUD.show(withStatus: name)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setForegroundColor (UIColor.mainBlack())
        SVProgressHUD.setBackgroundColor (UIColor.black.withAlphaComponent(0.0))
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setRingNoTextRadius(20)
        SVProgressHUD.setRingThickness(3)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
    }
    
    static func onhideProgressView() {
        SVProgressHUD.dismiss()
    }
    
    static func covertDateToString(dateFormat: String, date: Date) -> String{
        let df = DateFormatter()
        df.dateFormat = dateFormat
        let strDate = df.string(from: date)
        return strDate
    }
    
    static func convertStringToDate(dateFormat: String, date: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        let strDate = df.date(from: date)
        return strDate!
    }
    
    static func getDayOfWeek(date:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        guard let todayDate = formatter.date(from: date) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    static func isSameDate(date1: String, date2: String) -> Bool {
        let newDate1: String = date1.replacingOccurrences(of: " ", with: "").filter{!"\n".contains($0)}
        let newDate2: String = date2.replacingOccurrences(of: " ", with: "").filter{!"\n".contains($0)}
        let day1: Int = Int(newDate1.components(separatedBy: "-")[0])!
        let month1: Int = Int(newDate1.components(separatedBy: "-")[1])!
        let year1: Int = Int(newDate1.components(separatedBy: "-")[2])!
        if newDate2.contains("-") {
            let day2: Int = Int(newDate2.components(separatedBy: "-")[0])!
            let month2: Int = Int(newDate2.components(separatedBy: "-")[1])!
            let year2: Int = Int(newDate2.components(separatedBy: "-")[2])!
            
            if day1 == day2 && month1 == month2 && year1 == year2 {
                return true
            }
        }
        return false
    }
    
    static func createPDFFile(data: [OrderModel]) -> Data {

        let format = UIGraphicsPDFRendererFormat()
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            for order in data {
                context.beginPage()
                
                let titleBottom = addTitle(pageRect: pageRect, order: order)
                let subTitleBottom1 = addBodyText(pageRect: pageRect, textTop: titleBottom + 4.0, order: order, index: 1)
                let subTitleBottom2 = addBodyText(pageRect: pageRect, textTop: subTitleBottom1 + 4.0, order: order, index: 2)
                let comment = addDateText(pageRect: pageRect, textTop: subTitleBottom2 + 8.0, order: order, index: 1)
                let adminNote = addDateText(pageRect: pageRect, textTop: comment + 8.0, order: order, index: 2)
                let orderContent = addOrderText(pageRect: pageRect, textTop: adminNote + 8.0, order: order)
                let totalPrice = addTotalPrice(pageRect: pageRect, textTop: orderContent + 4.0, order: order)
                addBorderLine(pageRect: pageRect, textTop: totalPrice + 4.0)
            }
            
        }
        return data
    }
    
    static func addTitle(pageRect: CGRect, order: OrderModel) -> CGFloat {
        let context = UIGraphicsGetCurrentContext()
        for region in Utils.gRegions {
            if order.shippingPerson.region == region.title {
                context!.setFillColor(UIColor.hexStringToUIColor(hex: region.color).cgColor)
            }
        }
        context?.fill(CGRect(x: 13, y: 19, width: 55, height: 24))
        let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        
        let weekIndex = getDayOfWeek(date: order.deliveryDate)
        let date = convertStringToDate(dateFormat: "dd-MM-yyyy", date: order.deliveryDate)
        let dayString = covertDateToString(dateFormat: "dd", date: date)
        let monthString: String = covertDateToString(dateFormat: "MMMM", date: date)
        let strTitle = "#\(order.orderNumber)     \(AppConst.weeksStrings[weekIndex! - 1]) \(dayString) \(monthString)"
        
        let attributedTitle = NSAttributedString(string: strTitle, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(x: 20, y: 22, width: Int(pageRect.size.width), height: Int(titleStringSize.height))
        
        attributedTitle.draw(in: titleStringRect)
        
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    static func addBodyText(pageRect: CGRect, textTop: CGFloat, order: OrderModel, index: Int) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        var strBody = ""
        if index == 1 {
            strBody = order.shippingPerson.name + "  " + order.shippingPerson.phone
        } else if index == 2 {
            strBody = order.shippingPerson.street + ",  " + order.shippingPerson.city
        }
        
        let attributedText = NSAttributedString(string: strBody, attributes: textAttributes)
        let textRect = CGRect(x: 30, y: textTop, width: attributedText.size().width, height: attributedText.size().height)
        attributedText.draw(in: textRect)
        
        return textRect.origin.y + attributedText.size().height
    }
    
    static func addDateText(pageRect: CGRect, textTop: CGFloat, order: OrderModel, index: Int) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        var strBody = ""
        if index == 1 {
            strBody = order.orderComments
            if strBody.isEmpty {
                return textTop - 8.0
            }
        } else if index == 2 {
            strBody = order.adminNote
        }
        
        let attributedText = NSAttributedString(string: strBody, attributes: textAttributes)
        let textRect = CGRect(x: 30, y: textTop, width: attributedText.size().width, height: attributedText.size().height)
        attributedText.draw(in: textRect)
        
        return textRect.origin.y + attributedText.size().height
    }
    
    static func addOrderText(pageRect: CGRect, textTop: CGFloat, order: OrderModel) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        var i = 1
        var  top = textTop
        for product in order.products {
            let strBody = "\(i): " + product.name
            let attributedText = NSAttributedString(string: strBody, attributes: textAttributes)
            let textRect = CGRect(x: 30, y: top, width: attributedText.size().width, height: attributedText.size().height)
            attributedText.draw(in: textRect)
            top = textRect.origin.y + attributedText.size().height + 2.0
            
            let strPrice = String(format: "%.2f", Float(product.quantity) * Float(product.price))
            let strSubBody = "prijs: " + strPrice + "   hoeveelheid: \(product.quantity) X " + product.value
            let attributedText1 = NSAttributedString(string: strSubBody, attributes: textAttributes)
            let textRect1 = CGRect(x: 40, y: top, width: attributedText1.size().width, height: attributedText1.size().height)
            attributedText1.draw(in: textRect1)
            
            top = textRect1.origin.y + attributedText1.size().height + 8.0
            i += 1
            
        }
        return top
    }
    
    static func addTotalPrice(pageRect: CGRect, textTop: CGFloat, order: OrderModel) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        let strBody = "All prijs:   € " + String(format: "%.2f", order.total)
        
        let attributedText = NSAttributedString(string: strBody, attributes: textAttributes)
        let textRect = CGRect(x: 20, y: textTop, width: attributedText.size().width, height: attributedText.size().height)
        attributedText.draw(in: textRect)
        
        return textRect.origin.y + attributedText.size().height
    }
    
    static func addBorderLine(pageRect: CGRect, textTop: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.mainBlack().cgColor)
        context?.fill(CGRect(x: 20, y: textTop, width: pageRect.width - 40, height: 2.0))
    }
}
