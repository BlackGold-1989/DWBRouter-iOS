//
//  UserModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class UserModel: NSObject {
    var id: String = ""
    var name: String = ""
    var phone: String = ""
    var address: String = ""
    var regdate: String = ""
    var type: String = ""
    
    func fromFirebase(data: [String: Any]) {
        id = data["id"] as! String
        if let nameVal = data["name"] {
            name = nameVal as! String
        } else {
            name = ""
        }
        phone = data["phone"] as! String
        regdate = data["regdate"] as! String
        if let addressVal = data["address"] {
            address = addressVal as! String
        } else {
            address = ""
        }
        if let typeVal = data["type"] {
            type = typeVal as! String
        } else {
            type = ""
        }
    }
    
    func toFirebase() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "phone": phone,
            "address": address,
            "regdate": regdate,
            "type": type
        ]
    }
}
