//
//  CheckListModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class CheckListModel: NSObject {
    var id: String = ""
    var day: String = ""
    var month: String = ""
    var numMonth: String = ""
    var year: String = ""
    var week: String = ""
    var region: String = ""
    var color: String = ""
    var carid: String = ""
    var userid: String = ""
    var amount: String = ""
    
    func toFirebase() -> [String: Any] {
        return [
            "id": id,
            "day": day,
            "month": month,
            "numMonth": numMonth,
            "year": year,
            "week": week,
            "region": region,
            "color": color,
            "userid": userid,
            "carid": carid,
            "amount": amount
        ]
    }
    
    func fromFirebase(data: [String: Any]) {
        id = data["id"] as! String
        day = data["day"] as! String
        month = data["month"] as! String
        numMonth = data["numMonth"] as! String
        year = data["year"] as! String
        week = data["week"] as! String
        userid = data["userid"] as! String
        region = data["region"] as! String
        color = data["color"] as! String
        carid = data["carid"] as! String
        amount = data["amount"] as! String
    }
}
