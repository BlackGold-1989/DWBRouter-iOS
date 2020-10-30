//
//  OrderModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import SwiftyJSON

class OrderModel: NSObject {
    var orderNumber: String = ""
    var refundedAmount: Double = 0.0
    var subtotal: Double = 0.0
    var total: Double = 0.0
    var email: String = ""
    var datetime: String = ""
    var orderComments: String = ""
    var paymentStatus: String = ""
    var fulfillmentStatus: String = ""
    var ipAddress: String = ""
    var customerID: String = ""
    var deliveryDate: String = ""
    var adminNote: String = ""
    var shippingPerson: PersonModel = PersonModel()
    var products: [ProductModel] = [ProductModel]()
    var isCheck: Bool = false
    var isCheckDeliver: Bool = false
    
    
    func initWithJSON(data: JSON) {
        if let orderNumVal = data["vendorOrderNumber"].string {
            orderNumber = orderNumVal
        } else {
            orderNumber = ""
        }
        
        isCheck = false;
        isCheckDeliver = false;

        if let refundVal = data["refundedAmount"].double {
            refundedAmount = refundVal
        } else {
            refundedAmount = 0.0
        }

        if let subTotalVal = data["subtotal"].double {
            subtotal = subTotalVal
        } else {
            subtotal = 0.0
        }

        if let totalVal = data["total"].double {
            total = totalVal
        } else {
            total = 0.0
        }

        if let emailVal = data["email"].string {
            email = emailVal
        } else {
            email = ""
        }

        if let dateTimeVal = data["updateDate"].string {
            datetime = dateTimeVal
        } else {
            datetime = ""
        }

        if let paymentStatusVal = data["paymentStatus"].string {
            paymentStatus = paymentStatusVal
        } else {
            paymentStatus = ""
        }

        if let fulfillVal = data["fulfillmentStatus"].string {
            fulfillmentStatus = fulfillVal
        } else {
            fulfillmentStatus = ""
        }

        if let ipVal = data["ipAddress"].string {
            ipAddress = ipVal
        } else {
            ipAddress = ""
        }

        if let customerVal = data["customerId"].string {
            customerID = customerVal
        } else {
            customerID = ""
        }
        
        if let adminNoteVal = data["privateAdminNotes"].string {
            adminNote = adminNoteVal
            if deliveryDate.count == 0 && adminNote.count > 13 {
                deliveryDate = String(adminNote.substring(with: 13..<23))
            }
        } else {
            adminNote = ""
            deliveryDate = ""
        }
        
        if deliveryDate.isEmpty {
            if let extraVal = data["extraFields"].dictionaryObject {
                if let deliveryDateVal = extraVal["cstmz_delivery_date"] {
                    deliveryDate = deliveryDateVal as! String
                } else {
                    deliveryDate = ""
                }
            } else {
                deliveryDate = ""
            }
        }

        if let shippingVal = data["shippingPerson"].dictionaryObject {
            shippingPerson.initWithJSON(data: shippingVal)
        } else {
            if let shippingVal = data["billingPerson"].dictionaryObject {
                shippingPerson.initWithJSON(data: shippingVal)
            } else {
                shippingPerson = PersonModel()
            }
        }
        products.removeAll()

        if let productArr = data["items"].array {
            for i in 0..<productArr.count {
                let model: ProductModel = ProductModel()
                model.initWithJSON(data: productArr[i])
                products.append(model)
            }
        }

        if let orderCommentsVal = data["orderComments"].string {
            orderComments = orderCommentsVal
        } else {
            orderComments = ""
        }
    }
}
