//
//  block.swift
//  Tetris
//
//  Created by canaan1008 on 2018/03/06.
//  Copyright © 2018年 canaan1008. All rights reserved.
//

import Foundation

/* 操作中となるブロックのクラス */
class UnsettledBlock{
    var block: BlockData        /* ブロックの種類 */
    var y : Int                 /* ブロックの中心座標 */
    var x : Int
    var structure:[(Int,Int)]   /* (y, x) そのブロックの構成 */
    var direction : Int
    
    /* initializer */
    init(block:BlockData, y:Int, x:Int, structure:[(Int,Int)], direction: Int){
        self.block = block
        self.y = y
        self.x = x
        self.structure = structure
        self.direction = direction
    }
    
    /* 右回転 */
    func rotRight(){
        direction = (direction + 1) % self.block.rotate
        if(self.block.type != .O){
            for i in 0...3{
                let yy = self.structure[i].0
                let xx = self.structure[i].1
                self.structure[i].0 = -xx
                self.structure[i].1 = +yy
            }
        }
        
        if(self.block.type == .I){ /* Iブロックの回転処理 */
            switch direction{
            case 1: /* 0 -> 1 */
                self.x += 1
                break
            case 2: /* 1 -> 2 */
                self.y -= 1
                break
            case 3: /* 2 -> 3 */
                self.x -= 1
                break
            case 0: /* 3 -> 0 */
                self.y += 1
                break
            default:
                break
            }
        }
    }
    
    /* 左回転 */
    func rotLeft(){
        direction = (direction + self.block.rotate - 1) % self.block.rotate
        if(self.block.type != .O){
            for i in 0...3{
                let yy = self.structure[i].0
                let xx = self.structure[i].1
                self.structure[i].0 = +xx
                self.structure[i].1 = -yy
            }
        }
        
        if(self.block.type == .I){ /* Iブロックの回転処理 */
            switch direction{
            case 3: /* 0 -> 3 */
                self.y -= 1
                break
            case 2: /* 3 -> 2 */
                self.x += 1
                break
            case 1: /* 2 -> 1 */
                self.y += 1
                break
            case 0: /* 1 -> 0 */
                self.x -= 1
                break
            default:
                break
            }
        }
    }
    
    /* ブロックが置けるかどうか */
    func isAbleToPutBlock(field: [[Int]]) -> Bool{
        var yy : Int /* 構成しているブロックの座標 */
        var xx : Int
        for i in 0...3{
            yy = self.y + self.structure[i].0
            xx = self.x + self.structure[i].1
            
            if(!(0 <= yy /*&& yy <= 19 */ && 0 <= xx && xx <= 9) || field[yy][xx] != 0){
                return false
            }
        }
        return true
    }
}


class _currentBlock: UnsettledBlock{
    
    /*
     J, L, S, T, Z Tetromino Wall Kick Data(x,y)
     Test 1     Test 2     Test 3     Test 4     Test 5
     0>>1       ( 0, 0)    (-1, 0)    (-1, 1)    ( 0,-2)    (-1,-2)
     1>>0       ( 0, 0)    ( 1, 0)    ( 1,-1)    ( 0, 2)    ( 1, 2)
     1>>2       ( 0, 0)    ( 1, 0)    ( 1,-1)    ( 0, 2)    ( 1, 2)
     2>>1       ( 0, 0)    (-1, 0)    (-1, 1)    ( 0,-2)    (-1,-2)
     2>>3       ( 0, 0)    ( 1, 0)    ( 1, 1)    ( 0,-2)    ( 1,-2)
     3>>2       ( 0, 0)    (-1, 0)    (-1,-1)    ( 0, 2)    (-1, 2)
     3>>0       ( 0, 0)    (-1, 0)    (-1,-1)    ( 0, 2)    (-1, 2)
     0>>3       ( 0, 0)    ( 1, 0)    ( 1, 1)    ( 0,-2)    ( 1,-2)
     
     I Tetromino Wall Kick Data(x,y)
     Test 1     Test 2     Test 3     Test 4     Test 5
     0>>1       ( 0, 0)    (-2, 0)    ( 1, 0)    (-2,-1)    ( 1, 2)
     1>>0       ( 0, 0)    ( 2, 0)    (-1, 0)    ( 2, 1)    (-1,-2)
     1>>2       ( 0, 0)    (-1, 0)    ( 2, 0)    (-1, 2)    ( 2,-1)
     2>>1       ( 0, 0)    ( 1, 0)    (-2, 0)    ( 1,-2)    (-2, 1)
     2>>3       ( 0, 0)    ( 2, 0)    (-1, 0)    ( 2, 1)    (-1,-2)
     3>>2       ( 0, 0)    (-2, 0)    ( 1, 0)    (-2,-1)    ( 1, 2)
     3>>0       ( 0, 0)    ( 1, 0)    (-2, 0)    ( 1,-2)    (-2, 1)
     0>>3       ( 0, 0)    (-1, 0)    ( 2, 0)    (-1, 2)    ( 2,-1)
     from http://tetris.wikia.com/wiki/SRS
     */
    let WallKick_Right_JLSTZ = [ /* (y,x)の順で書かれているので注意！！！！ */
        /*  test[0]     test[1]     test[2]     test[3]     test[4]  */
        [   ( 0, 0),    ( 0,-1),    (-1,-1),    ( 2, 0),    ( 2,-1) ],  /* 3 >> [0] */
        [   ( 0, 0),    ( 0,-1),    ( 1,-1),    (-2, 0),    (-2,-1) ],  /* 0 >> [1] */
        [   ( 0, 0),    ( 0, 1),    (-1, 1),    ( 2, 0),    ( 2, 1) ],  /* 1 >> [2] */
        [   ( 0, 0),    ( 0, 1),    ( 1, 1),    (-2, 0),    (-2, 1) ]   /* 2 >> [3] */
    ]
    let WallKick_Left_JLSTZ = [/* (y,x)の順で書かれているので注意！！！！ */
        /*  test[0]     test[1]     test[2]     test[3]     test[4]  */
        [   ( 0, 0),    ( 0, 1),    (-1, 1),    ( 2, 0),    ( 2, 1)],   /* 1 >> [0] */
        [   ( 0, 0),    ( 0,-1),    ( 1,-1),    (-2, 0),    (-2,-1)],   /* 2 >> [1] */
        [   ( 0, 0),    ( 0,-1),    (-1,-1),    ( 2, 0),    ( 2,-1)],   /* 3 >> [2] */
        [   ( 0, 0),    ( 0, 1),    ( 1, 1),    (-2, 0),    (-2, 1)]    /* 0 >> [3] */
    ]
    
    let WallKick_Right_I = [/* (y,x)の順で書かれているので注意！！！！ */
        /*  test[0]     test[1]     test[2]     test[3]     test[4]  */
        [   ( 0, 0),    ( 0, 1),    ( 0,-2),    (-2, 1),    ( 1,-2)],   /* 3 >> [0] */
        [   ( 0, 0),    ( 0,-2),    ( 0, 1),    (-2,-1),    ( 2, 1)],   /* 0 >> [1] */
        [   ( 0, 0),    ( 0,-1),    ( 0, 2),    ( 2,-1),    (-1, 2)],   /* 1 >> [2] */
        [   ( 0, 0),    ( 0, 2),    ( 0,-1),    ( 1, 2),    (-2,-1)]    /* 2 >> [3] */
    ]
    
    let WallKick_Left_I = [/* (y,x)の順で書かれているので注意！！！！ */
        /*  test[0]     test[1]     test[2]     test[3]     test[4]  */
        [   ( 0, 0),    ( 0, 2),    ( 0,-1),    ( 1, 2),    (-2,-1)],   /* 1 >> [0] */
        [   ( 0, 0),    ( 0, 1),    ( 0,-2),    (-2, 1),    ( 1,-2)],   /* 2 >> [1] */
        [   ( 0, 0),    ( 0,-2),    ( 0, 1),    (-1,-2),    ( 2, 1)],   /* 3 >> [2] */
        [   ( 0, 0),    ( 0,-1),    ( 0, 2),    ( 2,-1),    (-1, 2)]    /* 0 >> [3] */
    ]
    
    
    func moveRight(field:[[Int]]) -> Bool{
        self.x += 1
        if(!isAbleToPutBlock(field:field)){
            self.x -= 1
            return false
        }
        return true
    }
    func moveLeft(field:[[Int]]) -> Bool{
        self.x -= 1
        if(!isAbleToPutBlock(field:field)){
            self.x += 1
            return false
        }
        return true
    }
    func moveDown(field:[[Int]]) -> Bool{
        self.y -= 1
        if(!isAbleToPutBlock(field:field)){
            self.y += 1
            return false
        }
        return true
    }
    func rotRight(field:[[Int]]) -> Bool{
        super.rotRight()
        
        var isSuccessRotate = false
        let (keep_y, keep_x) = (self.y, self.x) /* テスト前の座標 */
        
        
        switch self.block.type {
        case .O:
            isSuccessRotate = true
            break
        case .J, .L, .S, .Z, .T:
            for i in 0...4{
                self.y = keep_y + WallKick_Right_JLSTZ[direction][i].0 /* 自分の位置をずらしてみて… */
                self.x = keep_x + WallKick_Right_JLSTZ[direction][i].1
                if(isAbleToPutBlock(field:field)){      /* 置けるようだったら */
                    isSuccessRotate = true
                    break                               /* 抜け出す(そこに決定) */
                } else {
                    (self.y, self.x) = (keep_y, keep_x) /* 置けないようなら元に戻す */
                }
            }
            break
        case .I:
            for i in 0...4{
                self.y = keep_y + WallKick_Right_I[direction][i].0 /* 自分の位置をずらしてみて… */
                self.x = keep_x + WallKick_Right_I[direction][i].1
                if(isAbleToPutBlock(field:field)){      /* 置けるようだったら */
                    isSuccessRotate = true
                    break                               /* 抜け出す(そこに決定) */
                } else {
                    (self.y, self.x) = (keep_y, keep_x) /* 置けないようなら元に戻す */
                }
            }
            break
        }
        if(!isSuccessRotate){ /* もし回転が不可能なようなら元に戻す */
            super.rotLeft()
            return false
        }
        return true
        
    }
    func rotLeft(field:[[Int]]) -> Bool{
        super.rotLeft()
        
        var isSuccessRotate = false
        let (keep_y, keep_x) = (self.y, self.x) /* テスト前の座標 */
        
        
        switch self.block.type {
        case .O:
            isSuccessRotate = true
            break
        case .J, .L, .S, .Z, .T:
            for i in 0...4{
                self.y = keep_y + WallKick_Left_JLSTZ[direction][i].0 /* 自分の位置をずらしてみて… */
                self.x = keep_x + WallKick_Left_JLSTZ[direction][i].1
                if(isAbleToPutBlock(field:field)){      /* 置けるようだったら */
                    isSuccessRotate = true
                    break                               /* 抜け出す(そこに決定) */
                } else {
                    (self.y, self.x) = (keep_y, keep_x) /* 置けないようなら元に戻す */
                }
            }
            break
        case .I:
            for i in 0...4{
                self.y = keep_y + WallKick_Left_I[direction][i].0 /* 自分の位置をずらしてみて… */
                self.x = keep_x + WallKick_Left_I[direction][i].1
                if(isAbleToPutBlock(field:field)){      /* 置けるようだったら */
                    isSuccessRotate = true
                    break                               /* 抜け出す(そこに決定) */
                } else {
                    (self.y, self.x) = (keep_y, keep_x) /* 置けないようなら元に戻す */
                }
            }
            break
        }
        if(!isSuccessRotate){ /* もし回転が不可能なようなら元に戻す */
            super.rotRight()
            return false
        }
        return true
    }
}

