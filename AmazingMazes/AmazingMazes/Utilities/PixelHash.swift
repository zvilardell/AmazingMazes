//
//  PixelHash.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/24/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class PixelHash: NSObject {
    
    private var pixelHash: [CGPoint:PixelNode] = [:]
    
    //hash key to serve as the starting point of the maze represented by this pixel matrix
    var redPixelPoint: CGPoint!
    
    init?(from image: CGImage) {
        super.init()
        if let pixelData = image.dataProvider?.data {
            let bytesPerPixel: Int = image.bitsPerPixel / 8
            let pixelBytes: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            for y in 0..<image.height {
                for x in 0..<image.width {
                    let pixelIndex: Int = ((image.width * y) + x) * bytesPerPixel
                    let r = CGFloat(pixelBytes[pixelIndex]) / 255.0
                    let g = CGFloat(pixelBytes[pixelIndex + 1]) / 255.0
                    let b = CGFloat(pixelBytes[pixelIndex + 2]) / 255.0
                    let a = CGFloat(pixelBytes[pixelIndex + 3]) / 255.0
                    let color = UIColor(red: r, green: g, blue: b, alpha: a)
                    let point = CGPoint(x: x, y: y)
                    let node = PixelNode(point: point, in: self, withColor: color)
                    pixelHash[point] = node
                    if color == MazeColor.red && redPixelPoint == nil {
                        //save this node to serve as the starting point of our maze
                        redPixelPoint = point
                    }
                }
            }
        } else {
        	return nil
        }
    }
    
    subscript(key: CGPoint) -> PixelNode? {
        get {
            return pixelHash[key]
        }
    }
}

extension CGPoint: Hashable {
    public var hashValue: Int {
        //simple hash function from apple docs
        return x.hashValue ^ y.hashValue &* 16777619
    }
}

