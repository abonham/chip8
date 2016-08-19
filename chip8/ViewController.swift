//
//  ViewController.swift
//  chip8
//
//  Created by Aaron Bonham on 19/08/2016.
//  Copyright © 2016 Code Monastery. All rights reserved.
//

import Cocoa

//import UIKit

func hex(num: Int) -> String {
    
    return String(num, radix: 16)
}

class chip8 {
    var memory: [Int] = Array(count: 4096, repeatedValue: 0x0)
    var gfx: [UInt8] = Array(count: 64 * 32, repeatedValue: 0x0)
    var V: [Int] = Array(count: 16, repeatedValue: 0x0)
    var I: Int = 0x0
    var pc: Int = 0x0
    var opcode: Int = 0x0
    var stack: [Int] = Array(count: 16, repeatedValue: 0x0)
    var sp: Int = 0x0
    var key: [Int] = Array(count: 16, repeatedValue: 0x0)
    var drawFlag: Bool = false
    var backBuffer: NSImage?
    
    let fontSet: [Int] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80  // F
    ]
    
    let smile: [Int] = [0x12, 0x08, 0x24, 0x24, 0x00, 0x81, 0x42, 0x3C, 0xA2, 0x02, 0x62, 0x00, 0xC0, 0x3F, 0xC1, 0x1F, 0xD0, 0x16, 0x72, 0x01, 0x32, 0x20, 0x12, 0x0C, 0x00, 0xE0, 0x12, 0x0A]
    
    let chip8Table = [clearOrReturnFromSub, jump, cpuNull, jumpIfEqual, cpuNull, cpuNull, vXToNN, addNNToVX, cpuArithmatic, cpuNull, setIToAddress, cpuNull, randomNumberToVX, drawSprite, cpuNull, cpuNull]
    
    let cpuArithmaticTable = [cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull, cpuNull]
    
    func initialize() {
        for (index, char) in fontSet.enumerate() {
            memory[index] = char
        }
        
        for (index, byte) in smile.enumerate() {
            memory[index + 0x200] = byte
        }
        
        pc = 0x200
    }
    
    @objc func emulateCycle() {
        fetch()
        decode()
        execute()
        if drawFlag {
            drawGraphics()
            drawFlag = false
        }
    }
    
    func fetch() {
//                print("fetch")
        //        print("opcode \(hex(chip.opcode)), pc \(hex(pc))")
        opcode = memory[pc] << 8 | memory[pc + 1]
        
    }
    
    func decode() {
        
    }
    
    func execute() {
//        print("execute")
        let fn = chip8Table[(opcode & 0xF000) >> 12]
        fn(self)()
        
    }
    
    func cpuNull() {
        print("null")
        pc = pc + 2
    }
    
    func clearOrReturnFromSub() {
        switch opcode {
        case 0x00EE:
            pc = pc + 2
            break
        case 0x00E0:
            clearScreen()
            break
        default:
            pc = pc + 2
            break
        }
    }
    
    func clearScreen() {
//        print("clear screen")
        for (index, _) in gfx.enumerate() {
            gfx[index] = 0
        }
        drawFlag = true
        pc = pc + 2
    }
    
    func jump() {
        pc = opcode & 0x0FFF
        //        print("jump \(hex(pc))")
    }
    
    func jumpIfEqual() {
        if V[(opcode & 0x0F00) >> 8] == (opcode & 0x00FF) {
            pc += 4
            //            print("jumped (eq)")
        }
        else {
            pc = pc + 2
        }
    }
    
    
    func vXToNN() {
        V[(opcode & 0x0F00) >> 8] = (opcode & 0x00FF)
        pc = pc + 2
    }
    
    func addNNToVX() {
        //        print("V - \(hex(opcode))")
        V[(opcode & 0x0F00) >> 8] += (opcode & 0x00FF)
        //        print("add \(V[(opcode & 0x0F00) >> 8])")
        pc = pc + 2
    }
    
    func cpuArithmatic() {
        //        print("math")
        let fn = cpuArithmaticTable[opcode & 0x000F]
        fn(self)()
    }
    
    func setIToAddress() {
        I = opcode & 0x0FFF
        //        print(hex(I))
        pc = pc + 2
    }
    
    func randomNumberToVX() {
        let randomNumber = arc4random_uniform(0xFF)
        //        print("random \(hex(Int(randomNumber)))")
        V[(opcode & 0x0F00) >> 8] = (opcode & 0x00FF) & Int(randomNumber)
        pc = pc + 2
    }
    
    func drawSprite() {
        let x = V[(opcode & 0x0F00) >> 8];
        let y = V[(opcode & 0x00F0) >> 4];
        let height = opcode & 0x000F;
        var pixel: Int;
        
        V[0xF] = 0;
        for yline in 0..<height {
//        for (Int yline = 0; yline < height; yline++)
            pixel = memory[I + yline];
//            for(int xline = 0; xline < 8; xline++)
            for xline in 0..<8 {
                if((pixel & (0x80 >> xline)) != 0)
                {
//                    if(gfx[(x + xline + ((y + yline) * 64))] == 1) {
//                        V[0xF] = 1;
//                    }
                    let loc = x + xline + ((y + yline) * 64)
                    if loc < gfx.count {
                        gfx[loc] ^= 1;
                    }
                }
            }
        }
        
        
        drawFlag = true;
        pc += 2;
    }
    
    func drawGraphics() {
        
        let width  = 64 //Int(data[1]) | Int(data[0]) << 8
        let height = 32 //Int(data[3]) | Int(data[2]) << 8
        
        guard gfx.count >= width * height else {
            print("data not large enough to hold \(width)x\(height)")
            return
        }
        
        guard let colorSpace = CGColorSpaceCreateDeviceGray() else {
            print("color space is nil")
            return
        }
        
        guard let bitmapContext = CGBitmapContextCreate(nil, width, height, 8, width, colorSpace, CGImageAlphaInfo.None.rawValue) else {
            print("context is nil")
            return
        }
        
        let dataPointer = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(bitmapContext))
        for index in 0 ..< width * height {
            dataPointer[index] = gfx[index] * 255
        }
        
        guard let cgImage = CGBitmapContextCreateImage(bitmapContext) else {
            print("image is nil")
            return
        }
        self.backBuffer = NSImage(CGImage: cgImage, size: NSSize(width: 64, height: 32))
    }
}



class ViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        label.stringValue = "Start"
        
        let chip = chip8()
        chip.initialize()
        
//        NSTimer.scheduledTimerWithTimeInterval(0.03, target: chip, selector: #selector(chip8.emulateCycle), userInfo: nil, repeats: true)
        
        while true {
            chip.emulateCycle()
            imageView.image = chip.backBuffer
        }
        
//        for _ in 1...100220 {
//            label.stringValue = String(chip.opcode, radix: 16)
//            chip.emulateCycle()
//        }
        
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

