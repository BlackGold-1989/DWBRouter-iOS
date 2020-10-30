//
//  CarServiceModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class CarServiceModel: NSObject {
    var id: String = ""
    var name: String = ""
    var regdate: String = ""
    
    func fromFirebase(data: [String: Any]) {
        id = data["id"] as! String
        name = data["name"] as! String
        regdate = data["regdate"] as! String
    }
    
    func toFirebase() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "regdate": regdate
        ]
    }
}
