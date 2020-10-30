//
//  APIManager.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {
    static var baseUrl: String = "https://app.ecwid.com/api/v3/25016280/"
    static var token: String = "secret_eiqf1KHwhXPJMAxv4HemTm3Vj5uSTV6e"
    
    static var API_GET_ORDER = baseUrl + "orders"
    
    static func apiConnection(param: [String: String], url: String, method: HTTPMethod, success: @escaping ((JSON) -> Void)) {
        Alamofire.request(url, method: method, parameters: param).validate().responseJSON { (response) in
            if response.error != nil {
                Utils.onhideProgressView()
                return
            }
            if let data = response.result.value {
                let json = JSON.init(data)
                success(json)
            }
        }
    }
    
    static func apiConnectionReturn(param: [String: String], url: String, method: HTTPMethod, success: @escaping ((JSON, Bool) -> Void)) {
        Alamofire.request(url, method: method, parameters: param).validate().responseJSON { (response) in
            var isSuccess: Bool = false
            if response.error != nil {
                Utils.onhideProgressView()
                return
            }
            if let data = response.result.value {
                let json = JSON.init(data)
                isSuccess = true
                success(json, isSuccess)
            }
        }
    }
}
