//
//  PersonModel.swift
//  dwb_router_ios
//
//  Created by Aira on 6/20/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import SwiftyJSON

class PersonModel: NSObject {
    var name: String = ""
    var phone: String = ""
    var postalCode: String = ""
    var stateOrProvinceCode: String = ""
    var stateOrProvinceName: String = ""
    var street: String = ""
    var city: String = ""
    var countryCode: String = ""
    var countryName: String = ""
    var region: String = ""
    
    var lat: String = "0.0"
    var lan: String = "0.0"
    
    func initWithJSON(data: [String: Any]) {
        if let nameVal = data["name"] {
            name = nameVal as! String
        } else {
            name = ""
        }
        
        if let postalVal = data["postalCode"] {
            postalCode = postalVal as! String
            if postalCode.count > 4 {
                for regionitem in Utils.gRegions {
                    for postal in regionitem.postal {
                        if postal == postalCode.prefix(4) {
                            region = regionitem.title
                        }
                    }
                }
            } else {
                region = Utils.gRegions[0].title
            }
        }
//            if postalCode.count > 4 {
//                for postal in AppConst.postalCodeDenHaag {
//                    let sub = postalCode.prefix(4)
//                    if sub == postal {
//                        region = AppConst.regions[1]
//                    }
//                }
//                
//                for postal in AppConst.postalDelft {
//                    let sub = postalCode.prefix(4)
//                    if sub == postal {
//                        region = AppConst.regions[2]
//                    }
//                }
//                
//                for postal in AppConst.postalWestland {
//                    let sub = postalCode.prefix(4)
//                    if sub == postal {
//                        region = AppConst.regions[3]
//                    }
//                }
//                
//                for postal in AppConst.postalSchiedam {
//                    let sub = postalCode.prefix(4)
//                    if sub == postal {
//                        region = AppConst.regions[4]
//                    }
//                }
//                
//                for postal in AppConst.postalRotteram {
//                    let sub = postalCode.prefix(4)
//                    if sub == postal {
//                        region = AppConst.regions[5]
//                    }
//                }
//            }
//            
//        } else {
//            postalCode = ""
//            region = AppConst.regions[0]
//        }
        
        if let proviceCode = data["stateOrProviceCode"] {
            stateOrProvinceCode = proviceCode as! String
        } else {
            stateOrProvinceCode = ""
        }
        
        if let stateName = data["stateOrProvinceName"] {
            stateOrProvinceName = stateName as! String
        } else {
            stateOrProvinceName = ""
        }
        
        if let streetVal = data["street"] {
            street = streetVal as! String
        } else {
            street = ""
        }
        
        if let cityVal = data["city"] {
            city = cityVal as! String
        } else {
            city = ""
        }
        
        if let countryCodeVal = data["countryCode"] {
            countryCode = countryCodeVal as! String
        } else {
            countryCode = ""
        }
                
        if let countryNameVal = data["countryName"] {
            countryName = countryNameVal as! String
        } else {
            countryName = ""
        }
        
        if let phoneVal = data["phone"] {
            phone = phoneVal as! String
        } else {
            phone = ""
        }
        
    }
}
