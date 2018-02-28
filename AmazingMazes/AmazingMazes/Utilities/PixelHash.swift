//
//  PixelHash.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/24/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class PixelHash: NSObject {
    
    private let imageScanningQueue = DispatchQueue(label: "imageScanning", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes.concurrent)
    private let hashWritingQueue = DispatchQueue(label: "hashWriting", qos: DispatchQoS.userInitiated)
    
    private var pixelHash: [CGPoint:PixelNode] = [:]
    
    //hash key to serve as the starting point of the maze represented by this pixel matrix
    var redPixelPoint: CGPoint!
    
    init?(from image: CGImage) {
        super.init()
        if let pixelData = image.dataProvider?.data {
            let bytesPerPixel: Int = image.bitsPerPixel / 8
            let pixelBytes: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let imageScanGroup = DispatchGroup()
            for y in 0..<image.height {
                //start new asyncronous task to scan pixel row
                imageScanGroup.enter()
                imageScanningQueue.async {[unowned self] in
                    for x in 0..<image.width {
                        let pixelIndex: Int = ((image.width * y) + x) * bytesPerPixel
                        let r = CGFloat(pixelBytes[pixelIndex]) / 255.0
                        let g = CGFloat(pixelBytes[pixelIndex + 1]) / 255.0
                        let b = CGFloat(pixelBytes[pixelIndex + 2]) / 255.0
                        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                        if color == MazeColor.black {
                            //don't hash black pixels (maze walls), only hash pixels representing the maze path
                            continue
                        }
                        let point = CGPoint(x: x, y: y)
                        let node = PixelNode(point: point, in: self, withColor: color)
                        self.hashWritingQueue.sync {
                            self.pixelHash[point] = node
                        }
                        if color == MazeColor.red && self.redPixelPoint == nil {
                            //save this node to serve as the starting point of our maze
                            self.redPixelPoint = point
                        }
                    }
                    //pixel row scanned, leave dispatch group
                    imageScanGroup.leave()
                }
            }
            //wait for all pixel rows to be scanned
            imageScanGroup.wait()
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
