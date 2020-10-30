//
//  UIView.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import UIKit

enum SHADOWTYPE {
    case LARGE, MEDIUM, SMALL
}

enum RuleScheme: Int {
    case black
    case gray
    case blue
    case green
    
    var color: UIColor {
        switch self {
        case .black:
            return UIColor(displayP3Red: 33.0 / 255.0, green: 33.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)
        case .gray:
            return UIColor(displayP3Red: 33.0 / 255.0, green: 33.0 / 255.0, blue: 33.0 / 255.0, alpha: 0.5)
        case .blue:
            return UIColor(displayP3Red: 101.0 / 255.0, green: 177.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        case .green:
            return UIColor(displayP3Red: 167.0 / 255.0, green: 198.0 / 255.0, blue: 95.0 / 255.0, alpha: 1.0)
        }
    }
}

extension UIView {
    func setShadowToUIView(radius: CGFloat = 10, type shawType: SHADOWTYPE = SHADOWTYPE.SMALL) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        switch shawType {
        case .LARGE:
            layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
            layer.shadowRadius = 15.0
            break
        case .MEDIUM:
            layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            layer.shadowRadius = 10.0
            break
        default:
            layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            layer.shadowRadius = 5.0
            break
        }
        
        layer.masksToBounds = false
        layer.cornerRadius = radius
    }
    
    func setRadius(color: UIColor, width: CGFloat, radius: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = radius
    }
}
