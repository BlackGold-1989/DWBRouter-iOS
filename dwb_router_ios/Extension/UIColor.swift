//
//  UIColor.swift
//  dwb_router_ios
//
//  Created by Aira on 6/19/20.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func hexStringToUIColor(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count == 8 {
            cString = cString.fromRGBAToARGB()
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        if cString.count == 8 {
            var red = (rgbValue & 0xFF000000) >> 24
            red = (red + 12) > 255 ? 255 : red + 12
            var green = (rgbValue & 0x00FF0000) >> 16
            green = (green + 19) > 255 ? 255 : green + 19
            var blue = (rgbValue & 0x0000FF00) >> 8
            blue = (blue + 16) > 255 ? 255 : blue + 16
            return UIColor(
                red: CGFloat(red) / 255,
                green: CGFloat(green) / 255,
                blue: CGFloat(blue) / 255,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255
            )
        }

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    class func mainBack() -> UIColor {
        return UIColor(named: "colorMainBack")!
    }
    
    class func mainBlack() -> UIColor {
        return UIColor(named: "colorMainBlack")!
    }
    
    class func mainGreen() -> UIColor {
        return UIColor(named: "colorMainGreen")!
    }
    
    class func mainGrey() -> UIColor {
        return UIColor(named: "colorMainGrey")!
    }
    
    class func mainLightGrey() -> UIColor {
        return UIColor(named: "colorMainLightGray")!
    }
    
    class func mainCellFirstGrey() -> UIColor {
        return UIColor(named: "colorMainCellFirstGrey")!
    }
    
    class func mainCellGrey() -> UIColor {
        return UIColor(named: "colorMainCellGrey")!
    }
    
    class func mainRoosterBlue() -> UIColor {
        return UIColor(named: "colorRoosterBlue")!
    }
    
    class func mainRoosterGreen() -> UIColor {
        return UIColor(named: "colorRoosterGreen")!
    }
    
    class func mainRoosterRed() -> UIColor {
        return UIColor(named: "colorRoosterRed")!
    }
    
    class func mainRoosterYellow() -> UIColor {
        return UIColor(named: "colorRoosterYellow")!
    }
    
    class func mainRoosterPink() -> UIColor {
        return UIColor(named: "colorRoosterPink")!
    }
}

extension UIColor {
    enum HexFormat {
        case RGB
        case ARGB
        case RGBA
        case RRGGBB
        case AARRGGBB
        case RRGGBBAA
    }

    enum HexDigits {
        case d3, d4, d6, d8
    }

    func hexString(_ format: HexFormat = .RRGGBBAA) -> String {
        let maxi = [.RGB, .ARGB, .RGBA].contains(format) ? 16 : 256

        func toI(_ f: CGFloat) -> Int {
            return min(maxi - 1, Int(CGFloat(maxi) * f))
        }

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        let ri = toI(r)
        let gi = toI(g)
        let bi = toI(b)
        let ai = toI(a)

        switch format {
        case .RGB:       return String(format: "#%X%X%X", ri, gi, bi)
        case .ARGB:      return String(format: "#%X%X%X%X", ai, ri, gi, bi)
        case .RGBA:      return String(format: "#%X%X%X%X", ri, gi, bi, ai)
        case .RRGGBB:    return String(format: "#%02X%02X%02X", ri, gi, bi)
        case .AARRGGBB:  return String(format: "#%02X%02X%02X%02X", ai, ri, gi, bi)
        case .RRGGBBAA:  return String(format: "#%02X%02X%02X%02X", ri, gi, bi, ai)
        }
    }

    func hexString(_ digits: HexDigits) -> String {
        switch digits {
        case .d3: return hexString(.RGB)
        case .d4: return hexString(.RGBA)
        case .d6: return hexString(.RRGGBB)
        case .d8: return hexString(.RRGGBBAA)
        }
    }
}
