//
//  PixelMatrix.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/24/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class PixelMatrix: NSObject {
    
    private var matrix: [[PixelNode]] = []
    
    //pixel node reference serves as the starting point of the maze represented by this pixel matrix
    var redPixelNode: PixelNode!
    
    var rows: Int { return self.matrix.count }
    var columns: Int { return matrix[0].count }
    
    init?(from image: CGImage) {
        super.init()
        if let pixelData = image.dataProvider?.data {
            let bytesPerPixel: Int = image.bitsPerPixel / 8
            let pixelBytes: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            var pixelRow: [PixelNode]
            for y in 0..<image.height {
                pixelRow = []
                for x in 0..<image.width {
                    let pixelIndex: Int = ((image.width * y) + x) * bytesPerPixel
                    let r = CGFloat(pixelBytes[pixelIndex]) / 255.0
                    let g = CGFloat(pixelBytes[pixelIndex + 1]) / 255.0
                    let b = CGFloat(pixelBytes[pixelIndex + 2]) / 255.0
                    let a = CGFloat(pixelBytes[pixelIndex + 3]) / 255.0
                    let color = UIColor(red: r, green: g, blue: b, alpha: a)
                    let point = CGPoint(x: x, y: y)
                    let node = PixelNode(point: point, in: self, withColor: color)
                    pixelRow.append(node)
                    if color == MazeColor.red && redPixelNode == nil {
                        //save this node to serve as the starting point of our maze
                        redPixelNode = node
                    }
                }
                matrix.append(pixelRow)
            }
        } else {
        	return nil
        }
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> PixelNode {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range.")
            return matrix[row][column]
        }
    }
    
    subscript(point: CGPoint) -> PixelNode? {
        get {
            let row = Int(point.y)
            let column = Int(point.x)
            return indexIsValid(row: row, column: column) ? matrix[row][column] : nil
        }
    }
}
