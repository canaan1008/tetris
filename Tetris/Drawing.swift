//
//  Drawing.swift
//  Tetris
//
//  Created by canaan1008 on 2018/03/06.
//  Copyright © 2018年 canaan1008. All rights reserved.
//

import Foundation
import Cocoa

struct colorList_RGB{
    static let RGBofBlock = [
        RGB(  33,   33,   33), /* none */
        RGB(255,  23,  68), /*  Z (Red)     */
        RGB(255, 145,   0), /*  L (Orange)  */
        RGB(255, 234,   0), /*  O (Yellow)  */
        RGB(118, 255,   3), /*  S (Green)   */
        RGB(  0, 229, 255), /*  I (Cyan)    */
        RGB( 41, 121, 255), /*  J (Blue)    */
        RGB(213,   0, 249)  /*  T (Purple)  */
    ]
}

class DrawField : NSView{
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current?.cgContext
        context?.addRect(dirtyRect)
        context?.fillPath()
    }
}

class DrawSquareByBlockColor : NSView{
    
    var blockcolor : Int
    init(frame: NSRect, color: Int) {
        self.blockcolor = color
        super.init(frame: frame)
        
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let context = NSGraphicsContext.current?.cgContext
        //if(1 <= blockcolor && blockcolor <= 7){
            NSColor.rgb(colorList_RGB.RGBofBlock[blockcolor]).set()
//        } else if(8 <= blockcolor && blockcolor <= 14){
//            NSColor.rgb_changeBrightness(rgb: colorList_RGB.RGBofBlock[blockcolor - 7], value: 0.3).set()
//        }
        context?.addRect(dirtyRect)
        context?.fillPath()
    }
    
}


class DrawGrid : NSView{
    
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current?.cgContext
        NSColor.rgb(60, 60, 60).set()
        
        for x in 0...10{
            context?.move(to: CGPoint(x : x * 22, y : 0))
            context?.addLine(to: CGPoint(x : x * 22, y : 441))
            context?.strokePath()
        }
        for y in 0...20{
            context?.move(to: CGPoint(x:0, y:y*22))
            context?.addLine(to: CGPoint(x:221, y:y*22))
            context?.strokePath()
        }
        
    }
}

class DrawBorderLine : NSView{
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current?.cgContext
        NSColor.rgb(238, 238, 238).set()
        
        context?.move(to: CGPoint(x:0,y:0))
        context?.addLine(to: CGPoint(x:self.bounds.width, y:0))
        context?.addLine(to: CGPoint(x:self.bounds.width, y:self.bounds.width))
        context?.addLine(to: CGPoint(x:0, y:self.bounds.width))
        context?.closePath()
        context?.strokePath()
        
    }
}

class DrawLineBetweenPoints : NSView{
    var _pointList : [CGPoint]
    var color : NSColor
    var isClose : Bool
    var lineWidth : CGFloat
    var offset : CGFloat
    init(frame: NSRect, pointList : [CGPoint], color : NSColor, lineWidth: CGFloat, isClose : Bool, offset : CGFloat = 0) {
        self._pointList = pointList
        self.color = color
        self.lineWidth = lineWidth
        self.isClose = isClose
        self.offset = offset
        super.init(frame: frame)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current?.cgContext
        color.set()
        context?.setLineWidth(lineWidth)

        var pointList = moveByOffset(offset: offset, list: _pointList)
        
        context?.move(to: pointList[0])
        for i in 1..<pointList.count{
            context?.addLine(to: pointList[i])
        }
        if(isClose){
            context?.closePath()
        }
        
        context?.strokePath()
    }
    
    func moveByOffset(offset: CGFloat, list:  [CGPoint]) -> [CGPoint]{
        var newList :[CGPoint] = []
        for i in 0..<list.count{
            newList.append(CGPoint(x: list[i].x + offset ,y: list[i].y + offset))
        }
        return newList
    }
}
