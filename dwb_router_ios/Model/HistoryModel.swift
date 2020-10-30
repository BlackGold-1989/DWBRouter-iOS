//
//  HistoryModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class HistoryModel: NSObject {
    var id: String = ""
    var name: String = ""
    var date: String = ""
    var key: String = ""
    var regions: [String] = [String]()
    var count: Int = 0
    
    func toFireBase() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "date": date,
            "count": count,
            "regions": regions,
            "key": key
        ]
    }
    
    func fromFirebase(data: [String: Any]) {
        id = data["id"] as! String
        name = data["name"] as! String
        date = data["date"] as! String
        key = data["key"] as! String
        count = data["count"] as! Int
        
        let regionDatas = data["regions"] as! [String]
        regions.removeAll()
        for region in regionDatas {
            regions.append(region)
        }
    }
}
