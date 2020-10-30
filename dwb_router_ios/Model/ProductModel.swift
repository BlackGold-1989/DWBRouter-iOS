//
//  ProductModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProductModel: NSObject {
    var id: String = ""
    var productId: String = ""
    var categoryId: String = ""
    var price: Double = 0
    var quantity: Int = 0
    var name: String = ""
    var imageUrl: String = ""
    var value: String = ""
    
    func initWithJSON(data: JSON) {
        
        if let idVal = data["id"].string {
            id = idVal
        } else {
            id = ""
        }
        
        if let productIDVal = data["productId"].string {
            productId = productIDVal
        } else {
            productId = ""
        }
        
        if let categoryIDVal = data["categoryId"].string {
            categoryId = categoryIDVal
        } else {
            categoryId = ""
        }
        
        if let priceVal = data["price"].double {
            price = priceVal
        } else {
            price = 0.0
        }
        
        if let quantityVal = data["quantity"].int {
            quantity = quantityVal
        } else {
            quantity = 0
        }
        
        if let nameVal = data["name"].string {
            name = nameVal
        } else {
            name = ""
        }
        
        if let json = data["selectedOptions"].array {
            if json.count > 0 {
                if let firstObj = json[0].dictionaryObject {
                    if let strVal = firstObj["value"] {
                        value = strVal as! String
                    } else {
                        value = ""
                    }
                } else {
                    value = ""
                }
            } else {
                value = ""
            }
        } else {
            value = ""
        }
        
        if let imgUrlVal = data["imageUrl"].string {
            imageUrl = imgUrlVal
        } else {
            imageUrl = ""
        }
    }
}
