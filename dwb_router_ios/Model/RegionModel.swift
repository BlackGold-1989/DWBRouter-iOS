//
//  RegionModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class RegionModel: NSObject {
    var id: String = ""
    var isCheck: Bool = false
    
    var title: String = ""
    var color: String = ""
    var postal: [String] = [String]()
    
    func fromFirebase(data: [String: Any]) {
        title = data["title"] as! String
        color = data["color"] as! String
        if let postalArr = data["postal"] {
            postal = postalArr as! [String]
        } else {
            postal = [String]()
        }
    }
    
    func toFirebase() -> [String: Any] {
        return [
            "title": title,
            "color": color,
            "postal": postal
        ]
    }
}
