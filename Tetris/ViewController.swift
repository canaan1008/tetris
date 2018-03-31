//
//  ViewController.swift
//  Tetris
//
//  Created by canaan1008 on 2018/03/02.
//  Copyright © 2018年 canaan1008. All rights reserved.
//

import Cocoa

struct SCORE{
    static let single = 40
    static let double = 100
    static let triple = 300
    static let tetris = 1200
}

class ViewController: NSViewController {
    
    var time = 0
    var pressingTime = 0
    var nonMovingTime = 0
    var settleThresholdTime = 100 /* 固定直前の遊び時間(遊びフレーム) */
    var gravityTime = 60 /* gravityTimeフレーム毎に１マス勝手に落ちる */
    let interval = 1.0/60 /* 60fps */
    let pressingThresholdTime = 6//7 /* 移動長押しのときに何フレーム毎に移動させるか */
    
    
    var level = 1
    var deletedLine = 0
    var score = 0
    
    @IBOutlet weak var tetrisFieldView: NSView!
    @IBOutlet weak var nextBox_1: NSView!
    @IBOutlet weak var nextBox_2: NSView!
    @IBOutlet weak var nextBox_3: NSView!
    
    @IBOutlet weak var _holdBox: NSView!
    
    @IBOutlet weak var label_line: NSTextField!
    @IBOutlet weak var label_level: NSTextField!
    @IBOutlet weak var label_score: NSTextField!
    
    
    var nextBoxes: [NSView] = []
    var holdBox = NSView()
    
    var gridView = NSView()
    var settledBlockView = NSView()
    var unsettledBlockView = NSView()
    
    let default_x = 4
    let default_y = 20
    
    var fieldwidth : Int = 0
    var fieldheight :Int = 0
    var blockwidth : Int = 0
    var blockheight : Int = 0
    
    
    /* field[y][x]  */
    var field = [[Int]](repeating:[Int](repeating:0, count:10), count:25)
    /*
     25 |
     .. |
     20 |.............
     19 |
     18 |
     17 |
     .. |
     2 |
     1 |
     0 L_____________
     0  1  2 .. 9
     */
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        /* いろいろ初期化 */
        fieldwidth = Int(tetrisFieldView.bounds.width)
        fieldheight = Int(tetrisFieldView.bounds.height)
        blockwidth = fieldwidth / 10
        blockheight = fieldheight / 20
        

        var rect = NSRect(x:0, y:0, width:nextBox_1.bounds.width, height:nextBox_1.bounds.height)
        let border1 = DrawBorderLine(frame: rect)
        nextBox_1.addSubview(border1)
        nextBoxes.append(border1)
        
        rect = NSRect(x:0, y:0, width:nextBox_2.bounds.width, height:nextBox_2.bounds.height)
        let border2 = DrawBorderLine(frame: rect)
        nextBox_2.addSubview(border2)
        nextBoxes.append(border2)
        
        rect = NSRect(x:0, y:0, width:nextBox_3.bounds.width, height:nextBox_3.bounds.height)
        let border3 = DrawBorderLine(frame: rect)
        nextBox_3.addSubview(border3)
        nextBoxes.append(border3)
        
        rect = NSRect(x:0, y:0, width:_holdBox.bounds.width, height:_holdBox.bounds.height)
        let borderhold = DrawBorderLine(frame:rect)
        _holdBox.addSubview(borderhold)
        
        holdBox = borderhold
        
        tetrisFieldView.layer?.borderWidth = 2
        tetrisFieldView.layer?.borderColor = NSColor.black.cgColor
        
       
        
        let newBlockNum = pickUpFromBlockBox().rawValue
        currentBlock    = _currentBlock(block: Block[newBlockNum], y: default_y, x: default_x, structure: Block[newBlockNum].structure, direction : 0)
        shadeBlock      = _currentBlock(block: Block[newBlockNum], y: default_y, x: default_x, structure: Block[newBlockNum].structure, direction : 0)
        
        gridView = DrawGrid(frame: NSRect(x:0, y:0, width:tetrisFieldView.bounds.width, height:tetrisFieldView.bounds.height))
        tetrisFieldView.addSubview(gridView)
        
        settledBlockView = SquareView(frame: NSRect(x:0, y:0, width:tetrisFieldView.bounds.width, height:tetrisFieldView.bounds.height))
        gridView.addSubview(settledBlockView)
        unsettledBlockView = SquareView(frame: NSRect(x:0, y:0, width:tetrisFieldView.bounds.width, height:tetrisFieldView.bounds.height))
        gridView.addSubview(unsettledBlockView)
        
        
        for _ in 0...5{
            nextBlocks.append(pickUpFromBlockBox())
        }
        drawNext()
        
        putCurrentBlock()
        drawUnsettledBlocks()
        
        
        self.timer = Timer.scheduledTimer(timeInterval:interval,target:self,selector:#selector(ViewController.timerCalled),userInfo:nil,repeats:true)
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    /* 7ブロックの基本的な情報(名前、色、相対的な位置) */
    let Block = [
        BlockData(type: BlockType.Z, color: BlockColor.Red,     structure: [(0,0), (+1,-1), (+1,+0), (+0,+1)], rotate: 4), /* Z */
        BlockData(type: BlockType.L, color: BlockColor.Orange,  structure: [(0,0), (+0,-1), (+0,+1), (+1,+1)], rotate: 4), /* L */
        BlockData(type: BlockType.O, color: BlockColor.Yellow,  structure: [(0,0), (+1,+1), (+1,+0), (+0,+1)], rotate: 1), /* O */
        BlockData(type: BlockType.S, color: BlockColor.Green,   structure: [(0,0), (+0,-1), (+1,+0), (+1,+1)], rotate: 4), /* S */
        BlockData(type: BlockType.I, color: BlockColor.Skyblue, structure: [(0,0), (+0,-1), (+0,+1), (+0,+2)], rotate: 4), /* I */
        BlockData(type: BlockType.J, color: BlockColor.Blue,    structure: [(0,0), (+1,-1), (+0,-1), (+0,+1)], rotate: 4), /* J */
        BlockData(type: BlockType.T, color: BlockColor.Purple,  structure: [(0,0), (+1,+0), (+0,-1), (+0,+1)], rotate: 4)  /* T */
    ]
    
    let FilledBlockBox = [
        BlockType.Z, BlockType.L, BlockType.O, BlockType.S, BlockType.I, BlockType.J, BlockType.T
    ]
    
    var BlockBox : [BlockType] = []
    var nextBlocks : [BlockType] = []
    
    /* 7つのブロックが入った袋(BlockBox)から1つ取り出す */
    /* 空っぽだったら充填する */
    func pickUpFromBlockBox() -> BlockType{
        if(BlockBox.count == 0){
            BlockBox = FilledBlockBox
        }
        
        /* BlockBoxの何番目を持ってくるか */
        let choosedBlockIndex = Int(arc4random_uniform(UInt32(BlockBox.count)))
        let choosedBlockType = BlockBox[choosedBlockIndex]
        
        BlockBox.remove(at: choosedBlockIndex)
        
        return choosedBlockType
    }
    
    var currentBlock : _currentBlock!
    var shadeBlock : _currentBlock!
    var holdBlock : BlockData?
    
    /* フィールドを描画 */
    func drawField(){
        /* クリーンアップ */
        for v in settledBlockView.subviews{
            v.removeFromSuperview();
        }
        
        for y in (0..<20).reversed(){
            for x in 0..<10{
                if(0 < field[y][x]){
                    
                    let blockrect = NSRect(x: blockwidth * x, y: blockheight * y, width : blockwidth, height: blockheight)
                    settledBlockView.addSubview(drawBlockPiece(blockColor: field[y][x], position: blockrect))
                    }
                }
                
            }
        
        
        drawShadeBlock()
    
    }
    
    func drawSettledBlocks(){
        /* クリーンアップ */
        for v in settledBlockView.subviews{
            v.removeFromSuperview();
        }
        
        for y in (0..<20).reversed(){
            for x in 0..<10{
                if(0 < field[y][x]){

                    let blockrect = NSRect(x: blockwidth * x, y: blockheight * y, width : blockwidth, height: blockheight)
                    settledBlockView.addSubview(drawBlockPiece(blockColor: field[y][x], position: blockrect))
                }
            }
        }
    }
    
    func drawUnsettledBlocks(){
        for v in unsettledBlockView.subviews{
            v.removeFromSuperview()
        }
        
        drawShadeBlock()

        
        for i in 0...3{
            let y = currentBlock.y + currentBlock.structure[i].0
            let x = currentBlock.x + currentBlock.structure[i].1
            
            let blockrect = NSRect(x: blockwidth * x, y: blockheight * y, width : blockwidth, height: blockheight)
            unsettledBlockView.addSubview(drawBlockPiece(blockColor: currentBlock.block.color.rawValue, position: blockrect))
        }
        

    }
    
    func drawBlockPiece(blockColor: Int, position: NSRect) -> NSView{
        
        let width = position.width
        let height = position.height
        
        var blockview = NSView()
        blockview = DrawSquareByBlockColor(frame: position, color: blockColor)
        
        var shade = NSView()
        var points = [CGPoint(x:0, y:0), CGPoint(x:width, y:0), CGPoint(x:width, y:height)]
        let blockrect_mini = NSRect(x: 0, y:0, width: blockwidth, height:blockheight)
        var color = NSColor.rgb_changeBrightness(rgb: colorList_RGB.RGBofBlock[blockColor], value: 0.6)
        shade = DrawLineBetweenPoints(frame:blockrect_mini, pointList : points, color: color, lineWidth : 2.5, isClose: false)
        blockview.addSubview(shade)
        
        var luster = NSView()
        points = [CGPoint(x:0,y:0), CGPoint(x:0, y:height), CGPoint(x:width,y:height)]
        color = NSColor.rgb_changeBrightness(rgb: colorList_RGB.RGBofBlock[blockColor], value: 1.5)
        luster = DrawLineBetweenPoints(frame:blockrect_mini, pointList : points, color: color, lineWidth : 2.5, isClose: false)
        blockview.addSubview(luster)
        
        return blockview
    }
    
    func hardDrop(){
        currentBlock = shadeBlock
        settleBlock()
    }
    
    /* ブロックを確定 & 次のブロックを置く */
    func settleBlock(){
        /* ゲームオーバーの判定(場外設置) */
        var flagGameOver = true
        for i in 0...3{
            let yy = currentBlock.y + currentBlock.structure[i].0
            if(yy < 20){
                flagGameOver = false
            }
        }
        if(flagGameOver){
            gameOver()
        }
        
        putCurrentBlock()
        checkDeleteLine()
        drawSettledBlocks()
        
        swappedInThisTurn = false
        
        let newBlockNum = nextBlocks.first?.rawValue
        nextBlocks.removeFirst()
        nextBlocks.append(pickUpFromBlockBox())
        currentBlock = _currentBlock(block:Block[newBlockNum!], y:default_y, x:default_x, structure: Block[newBlockNum!].structure, direction : 0)
        
        drawNext()
        
        /* ゲームオーバーの判定(重なり) */
        if(!currentBlock.isAbleToPutBlock(field: field)){
            gameOver()
        }
    }
    
    /* フィールドにcurrentBlock(と影)を入れる */
    func putCurrentBlock(){
        searchShade()

        for i in 0...3{
            let y = currentBlock.y + currentBlock.structure[i].0
            let x = currentBlock.x + currentBlock.structure[i].1
            field[y][x] = currentBlock.block.color.rawValue
        }
    }
    
    /* フィールドからcurrentBlock(と影)を消去 */
    func deleteCurrentBlock(){

        for i in 0...3{
            let y = currentBlock.y + currentBlock.structure[i].0
            let x = currentBlock.x + currentBlock.structure[i].1
            field[y][x] = 0
        }
    }
    
    /* 影の位置を探す */
    func searchShade(){
        shadeBlock.block = currentBlock.block
        shadeBlock.direction = currentBlock.direction
        shadeBlock.x = currentBlock.x
        shadeBlock.y = currentBlock.y
        shadeBlock.structure = currentBlock.structure
        
        while(shadeBlock.moveDown(field: field)){
        }
    }
    
    /* HOLDブロックとの入れ替え */
    var swappedInThisTurn = false
    func swapHoldBlock(){
        
        if(!swappedInThisTurn){
            swappedInThisTurn = true
            
            var temp : BlockData
            if(holdBlock == nil){
                holdBlock = currentBlock.block
                let newBlockNum = nextBlocks.first?.rawValue
                nextBlocks.removeFirst()
                nextBlocks.append(pickUpFromBlockBox())
                currentBlock = _currentBlock(block:Block[newBlockNum!], y:default_y, x:default_x, structure: Block[newBlockNum!].structure, direction : 0)
                drawNext()
            } else{
                temp = holdBlock!
                holdBlock = currentBlock.block
                currentBlock = _currentBlock(block:Block[temp.type.rawValue], y:default_y, x:default_x, structure: Block[temp.type.rawValue].structure, direction : 0)
            }
            drawHold(type: holdBlock!.type)
            drawUnsettledBlocks()
            
        }
    }
    
    /* called 30 times/sec */
    @objc func timerCalled(){
        time += 1
        
        if(time % gravityTime == 0){
            time = 0
            dropByGravity()
        }
        
        checkKeyPressing()
    }
    
    /* 重力による落下 */
    func dropByGravity(){
        if(!pressing_Down){/* 下入力が無かったら自動落下 */
            deleteCurrentBlock()
            if(!currentBlock.moveDown(field:field)){
                if(nonMovingTime > settleThresholdTime){
                    
                    //nonMovingTime = 0
                    settleBlock()
                }
                
            } else {
            nonMovingTime = 0
            }
            putCurrentBlock()
            drawUnsettledBlocks()
        }
    }
    
    /* １列揃っているところがあったら消す */
    func checkDeleteLine(){
        var y = 0
        
        var continuity_line = 0
        
        while(y < 25){
            var deleteFlag = true
            for x in 0...9{
                if (field[y][x] == 0){
                    deleteFlag = false;
                    
                    if(continuity_line > 0){
                        switch continuity_line{
                        case 1:
                            addScore(n: SCORE.single * level)
                            break
                        case 2:
                            addScore(n: SCORE.double * level)
                            break
                        case 3:
                            addScore(n: SCORE.triple * level)
                            break
                        case 4:
                            addScore(n: SCORE.tetris * level)
                            break
                        default :
                            break
                        }
                        continuity_line = 0
                    }
                    break
                }
            }
            
            if(deleteFlag){
                continuity_line += 1
                deletedLine += 1
                label_line.stringValue = "LINE: \(deletedLine)"
                
                if(deletedLine - level * 10 >= 0){
                    level += 1
                    label_level.stringValue = "LEVEL: \(level)"
                    gravityTime = Int(Double(gravityTime) * 0.8)
                }
                
                for j in y..<24{
                    for x in 0...9{
                        field[j][x] = field[j+1][x]
                    }
                }
                for x in 0...9{
                    field[24][x] = 0
                }
                y -= 1
                
            }
            y += 1
        }
        
        
        
        
    }
    
    /* ゲームオーバーの演出 */
    func gameOver(){
        for v in unsettledBlockView.subviews{
            v.removeFromSuperview()
        }
        
        self.timer?.invalidate()
        
        for y in 0..<25{
            for x in 0..<10{
                if(0 < field[y][x] && field[y][x] < 8){
                    field[y][x] = 1
                } else {
                    field[y][x] = 0
                }
            }
        }
        drawSettledBlocks()
        
    }
    
    
    
    /* Holdブロックの描画 */
    func drawHold(type: BlockType){
        drawBlockInBox(box: holdBox, blockdata: Block[type.rawValue])
    }
    
    /* Nextブロックの描画 */
    func drawNext(){
        for i in 0...2{
            drawBlockInBox(box:nextBoxes[i], blockdata:Block[nextBlocks[i].rawValue])
        }
    }
    
    /* 影ブロックの描画 */
    func drawShadeBlock(){
        
        /* 4 * 4に収まっている */
        /* 描画範囲のできるだけ左下に入れるとしてその左下の座標をまず求めたい */
        /*
         □□□□
         □□□□
         □□□□
         □□□□
         */
        
        var leftBottom_x : Int
        var leftBottom_y : Int
        
        var dx = 0
        var dy = 0
        var dx_into_view = 0
        var dy_into_view = 0

        switch shadeBlock.block.type {
        case .Z, .L, .S, .J, .T:
            switch shadeBlock.direction{
                /*
                 　　０　　　１　　　２　　　３
                 　ーーー　ー□ー　ーーー　ー□ー
                 　□□ー　■□ー　□■ー　□■ー
                 　ー■□　□ーー　ー□□　□ーー
                 dx   1     0     1     1
                 dy   0     1     1     1
                 */
            case 0:
                dx = 1
                break
            case 1:
                dy = 1
                dy_into_view = 3
                break
            case 2:
                dx = 1
                dy = 1
                dy_into_view = 2
                dx_into_view = 3
                break
            case 3:
                dx = 1
                dy = 1
                dx_into_view = 2
                break
            default:
                break
            }
            break
        case .O:
            break;
        case .I:
            switch shadeBlock.direction{
            case 0:
                dx = 1
                break
            case 1:
                dy = 2
                dy_into_view = 4
                break
            case 2:
                dx = 2
                dx_into_view = 4
                dy_into_view = 1
                break
            case 3:
                dy = 1
                dx_into_view = 1
                break
            default:
                break
            }
            break
        }
        
        leftBottom_y = blockheight * (shadeBlock.y - dy)
        leftBottom_x = blockwidth * (shadeBlock.x - dx)
        
        var view = NSView()
        let rect = NSRect(x:leftBottom_x - 3, y:leftBottom_y - 3, width: blockwidth * 5, height :blockheight * 5)
        
        view = DrawLineBetweenPoints(frame: rect,
                                     pointList :getPointListOfBlockOutline(type: shadeBlock.block.type,
                                                                           blockwidth: blockwidth,
                                                                           blockheihgt: blockheight,
                                                                           rotate: shadeBlock.direction,
                                                                           dx: dx_into_view,
                                                                           dy: dy_into_view),
                                     color : NSColor.rgb_changeBrightness(rgb: colorList_RGB.RGBofBlock[shadeBlock.block.color.rawValue],value: 1.5),
                                     lineWidth: 2.0,
                                     isClose : true,
                                     offset : 3)
        
        unsettledBlockView.addSubview(view)
        
    }
    
    func getPointListOfBlockOutline(type:BlockType, blockwidth : Int, blockheihgt: Int, rotate: Int, dx: Int, dy: Int) -> [CGPoint]{
        let w = blockwidth
        let h = blockheight
        
        var pointList : [CGPoint] = []
        
        let outlinedata_yx = BlockOutLine.outline_yx[type.rawValue]
        
        for i in 0..<outlinedata_yx.count{
            let (_y, _x) = outlinedata_yx[i]
            var ( y,  x) = (_y, _x)
            switch rotate{
            case 0:
                (y,x) = ( _y,  _x)
                break
            case 1:
                (y,x) = (-_x,  _y)
                break
            case 2:
                (y,x) = (-_y, -_x)
                break
            case 3:
                (y,x) = ( _x, -_y)
                break
            default:
                break
            }
            
            pointList.append(CGPoint(x: (x + dx) * w , y: (y + dy) * h))
        }
        return pointList
    }
    
    func addScore(n : Int){
        score += n
        label_score.stringValue = "\(score)"
    }
    
    var pressing_Right  = false
    var pressing_Left   = false
    var pressing_Up     = false
    var pressing_Down   = false
    var pressing_Z      = false
    var pressed_Z       = true
    var pressing_X      = false
    var pressed_X       = true
    var pressing_Space  = false
    var pressed_Space   = true
    var pressing_Shift  = false
    var pressed_Shift   = true
    var isMoving        = false
    
    /* キーが押されたときに何をするか */
    func checkKeyPressing(){
        nonMovingTime += 1
        
        if(!isMoving || pressingTime % pressingThresholdTime == 0){
            
            if(pressing_Right){
                isMoving = true
                deleteCurrentBlock()

                if(currentBlock.moveRight(field:field)){  nonMovingTime = 0  }
                putCurrentBlock()
                drawUnsettledBlocks()
            }
            if(pressing_Left){
                isMoving = true
                deleteCurrentBlock()

                if(currentBlock.moveLeft(field:field)){  nonMovingTime = 0  }
                putCurrentBlock()
                drawUnsettledBlocks()
            }
            if(pressing_Down){
                isMoving = true
                deleteCurrentBlock()
                if(!currentBlock.moveDown(field:field)){ /* 下に移動できなかったら… */
                    if(nonMovingTime > settleThresholdTime){
                        nonMovingTime = 0
                        settleBlock()
                    }
                }
                putCurrentBlock()
                drawUnsettledBlocks()
            }
            
        }
        pressingTime += 1
        
        if(!pressing_Right && !pressing_Left && !pressing_Down){
            pressingTime = 0
        }
        
        if(pressing_Space && pressed_Space){
            pressed_Space = false
            deleteCurrentBlock()

            nonMovingTime = 0
            hardDrop()
            putCurrentBlock()
            drawUnsettledBlocks()
        }
        if(pressing_Z && pressed_Z){
            pressed_Z = false
            deleteCurrentBlock()

            if(currentBlock.rotLeft(field:field)){  nonMovingTime = 0  }
            putCurrentBlock()
            drawUnsettledBlocks()
        }
        if(pressing_X && pressed_X){
            pressed_X  = false
            deleteCurrentBlock()

            if(currentBlock.rotRight(field:field)){  nonMovingTime = 0  }
            putCurrentBlock()
            drawUnsettledBlocks()
        }
        if(pressing_Shift && pressed_Shift){
            pressed_Shift = false
            deleteCurrentBlock()

            swapHoldBlock()
            
            putCurrentBlock()
            drawUnsettledBlocks()
        }
        
        
    }
    
    /* NSView型のboxの中央にBlockを載せる */
    /* 正方形を受け取るのを想定 */
    func drawBlockInBox(box: NSView, blockdata:BlockData){
        
        for v in box.subviews{
            v.removeFromSuperview()
        }
        
        let drawarea = box.bounds.width * 0.9
        let drawarea_leftbottom = box.bounds.width * 0.05
        let blocksize = drawarea / 4
        //let blockmargin = blocksize * 0.05
        
        var yo : CGFloat /* 中央ブロックの座標 */
        var xo : CGFloat
        
        switch blockdata.type{
        case .Z, .S, .J, .L, .T:
            /* 横3マス 縦2マス */
            /* 左下の(y,x)は(blocksize, blocksize/2) */
            yo = drawarea_leftbottom + blocksize
            xo = drawarea_leftbottom + blocksize * 3 / 2
            break
        case .I:
            /* 横4マス 縦1マス */
            /* 左下の(y,x)は(blocksize * 3/2, 0) */
            yo =  drawarea_leftbottom + blocksize * 3 / 2
            xo =  drawarea_leftbottom + blocksize
            break
        case .O:
            /* 横2マス 縦2マス*/
            /* 左下の(y,x)は(blocksize, blocksize) */
            yo = drawarea_leftbottom + blocksize
            xo = drawarea_leftbottom + blocksize
            break
        }
        for i in 0...3{
            let y = blocksize * CGFloat(blockdata.structure[i].0)
            let x = blocksize * CGFloat(blockdata.structure[i].1)

            let blockrect = NSRect(x:x + xo, y:y + yo, width: blocksize, height:blocksize)
            box.addSubview(drawBlockPiece(blockColor: blockdata.color.rawValue, position: blockrect))
            
        }
    }
    
    /* キーが押されたら呼び出される */
    override func keyDown(with event: NSEvent){
        /* event.keyCode で入力キーのキーコードが得られる */
        
        switch event.keyCode {
        case Keycode.rightArrow:
            pressing_Right = true
            break
        case Keycode.leftArrow:
            pressing_Left = true
            break
        case Keycode.downArrow:
            pressing_Down = true
            break
        case Keycode.upArrow:
            pressing_Up = true
            break
        case Keycode.space:
            pressing_Space = true
            break
        case Keycode.c:
            pressing_Shift = true
            break
        case Keycode.x:
            pressing_X = true
            break
        case Keycode.z:
            pressing_Z = true
            break
        default:
            break
        }
        
        
    }
    
    /* キーが離されたら呼び出される */
    override func keyUp(with event: NSEvent){
        /* event.keyCode で入力キーのキーコードが得られる */
        
        switch event.keyCode {
        case Keycode.rightArrow:
            pressing_Right = false
            isMoving = false
            break
        case Keycode.leftArrow:
            pressing_Left = false
            isMoving = false
            break
        case Keycode.downArrow:
            pressing_Down = false
            isMoving = false
            break
        case Keycode.upArrow:
            pressing_Up = false
            break
        case Keycode.space:
            pressing_Space = false
            pressed_Space = true
            break
        case Keycode.c:
            pressing_Shift = false
            pressed_Shift = true
            break
        case Keycode.x:
            pressing_X = false
            pressed_X = true
            break
        case Keycode.z:
            pressing_Z = false
            pressed_Z = true
            break
        default:
            break
        }
        
        
    }
    
}
