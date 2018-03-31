//
//  BlockData.swift
//  Tetris
//
//  Created by canaan1008 on 2018/03/06.
//  Copyright © 2018年 canaan1008. All rights reserved.
//

import Foundation

enum BlockType: Int{
    case Z = 0, L,O,S,I,J,T
}

enum BlockColor:Int{
    case Red = 1, Orange, Yellow, Green, Skyblue, Blue, Purple
    case Shade_Red = 8, Shade_orange, Shade_Yellow, Shade_Green, Shade_Skyblue, Shade_Blue, Shade_Purple
}

/* 全てのブロックが持っているデータ */
struct BlockData{
    var type:BlockType;
    var color:BlockColor;
    var structure:[(Int,Int)]; /* (y, x)*/
    var rotate : Int /* 回転量 */
}

struct BlockOutLine{
    static let outline_yx = [
        /* Z */
        [(0,1), (1,1), (1,0), (2,0), (2,1), (2,2), (1,2), (1,3), (0,3), (0,2)],
        /* L */
        [(0,0), (1,0), (1,2), (2,2), (2,3), (0,3)],
        /* O */
        [(0,0), (2,0), (2,2), (0,2), ],
        /* S */
        [(0,0), (1,0), (1,1), (2,1), (2,2), (2,3), (1,3), (1,2), (0,2), (0,1)],
        /* I */
        [(0,0), (1,0), (1,4), (0,4)],
        /* J */
        [(0,0), (2,0), (2,1), (1,1), (1,3), (0,3)],
        /* T */
        [(0,0), (1,0), (1,1), (2,1), (2,2), (1,2), (1,3), (0,3)]
    ]
}
