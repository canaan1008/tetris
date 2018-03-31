//
//  CustomView.swift
//  Tetris
//
//  Created by canaan1008 on 2018/03/02.
//  Copyright © 2018年 canaan1008. All rights reserved.
//

import Cocoa

class CustomView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        layer?.backgroundColor = NSColor.rgb(33,33,33).cgColor
    }
    
    override var acceptsFirstResponder: Bool { return true }
    
}

class SquareView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override var acceptsFirstResponder: Bool { return true }
    
}
