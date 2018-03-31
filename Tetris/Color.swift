//
//  Color.swift
//  Tetris
//
//  Created by canaan1008 on 2018/03/07.
//  Copyright © 2018年 canaan1008. All rights reserved.
//

import Foundation
import Cocoa



extension NSColor{
    class func rgb(_ r:Int, _ g: Int, _ b: Int, _ alpha:CGFloat = 1.0) -> NSColor{
        return NSColor(calibratedRed: CGFloat(r)/256.0, green: CGFloat(g)/256.0, blue:CGFloat(b)/256.0, alpha:alpha)
    }
    
    class func rgb(_ rgb : RGB, _ alpha:CGFloat = 1.0) -> NSColor{
        return NSColor(calibratedRed: rgb.r/256.0, green: rgb.g/256.0, blue:rgb.b/256.0, alpha:alpha)
    }
    
    class func hsv(_ h: CGFloat, _ s : CGFloat, _ v : CGFloat, _ alpha:CGFloat = 1.0) -> NSColor{
        return NSColor(calibratedHue: h, saturation: s, brightness: v, alpha:alpha)
    }

    class func hsv(_ hsv : HSV, _ alpha : CGFloat = 1.0) -> NSColor{
        return NSColor(calibratedHue: hsv.h, saturation: hsv.s, brightness: hsv.v, alpha:alpha)
    }
    
    class func rgb_changeBrightness(rgb:RGB, value: CGFloat) -> NSColor{
        let this_hsv = rgb.toHSV
        var new_v = this_hsv.v * value
        if(new_v > 1){ new_v = 1 }
        let new_hsv = HSV(h: this_hsv.h, s: this_hsv.s, v: this_hsv.v * value)
        let new_rgb = new_hsv.toRGB
        return NSColor.rgb(new_rgb)
    }
}

// https://www.cs.rit.edu/~ncs/color/t_convert.html
class RGB {
    // Percent
    let r: CGFloat // [0,1]
    let g: CGFloat // [0,1]
    let b: CGFloat // [0,1]
    let alpha: CGFloat
    
    init(_ r : CGFloat, _ g : CGFloat , _ b : CGFloat, _ alpha : CGFloat = 1.0){
        self.r = r
        self.g = g
        self.b = b
        self.alpha = alpha
    }
    
     func rgb2hsv(r: CGFloat, g: CGFloat, b: CGFloat) -> HSV {
        let min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        let max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else { return HSV(h: 0, s: 0, v: max) }
        guard max > 0 else { return HSV(h: -1, s: 0, v: v) } // Undefined, achromatic grey
        let s = delta / max
        
        let hue: (CGFloat, CGFloat) -> CGFloat = { max, delta -> CGFloat in
            if r == max { return (g-b)/delta } // between yellow & magenta
            else if g == max { return 2 + (b-r)/delta } // between cyan & yellow
            else { return 4 + (r-g)/delta } // between magenta & cyan
        }
        
        let h = hue(max, delta) * 60 // In degrees
        
        return HSV(h: (h < 0 ? h+360 : h) , s: s, v: v)
    }
    
     func rgb2hsv(_ rgb: RGB) -> HSV {
        return rgb2hsv(r: rgb.r, g: rgb.g, b: rgb.b)
    }
    
    var toHSV: HSV {
        return rgb2hsv(self)
    }
    
     func changeBrightness(value : CGFloat) -> RGB{ /* value : [0, 1] */
        let this_hsv = self.toHSV
        let new_brightness = this_hsv.v * value
        return HSV(h: this_hsv.h, s: this_hsv.s, v:new_brightness).toRGB
    }
    
}

struct HSV {
    let h: CGFloat // Angle in degrees [0,360] or -1 as Undefined
    let s: CGFloat // Percent [0,1]
    let v: CGFloat // Percent [0,1]
    
     func hsv2rgb(_ h: CGFloat, _ s: CGFloat, _ v: CGFloat) -> RGB {
        if s == 0 { return RGB(v, v, v) } // Achromatic grey
        
        let angle = (h >= 360 ? 0 : h)
        let sector = angle / 60 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h
        
        let p = v * (1 - s)
        let q = v * (1 - (s * f))
        let t = v * (1 - (s * (1 - f)))
        
        switch(i) {
        case 0:
            return RGB(v, t, p)
        case 1:
            return RGB(q, v, p)
        case 2:
            return RGB(p, v, t)
        case 3:
            return RGB(p, q, v)
        case 4:
            return RGB(t, p, v)
        default:
            return RGB(v, p, q)
        }
    }
    
     func hsv2rgb(_ hsv: HSV) -> RGB {
        return hsv2rgb(hsv.h, hsv.s, hsv.v)
    }
    
    var toRGB: RGB {
        return hsv2rgb(self)
    }
    
    /// Returns a normalized point with x=h and y=v
    var point: CGPoint {
        return CGPoint(x: CGFloat(h/360), y: CGFloat(v))
    }
}
