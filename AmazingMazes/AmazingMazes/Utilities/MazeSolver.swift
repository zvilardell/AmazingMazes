//
//  MazeSolver.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/23/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class MazeSolver: NSObject {
    
    typealias SolveMazeCompletion = (Bool, UIImage?)->()
    
    //---------------------------------------------------------------------------------------------------------------------------
    //singleton setup
    
    static let sharedInstance = MazeSolver()
    private override init() {
        super.init()
    }
    
    //---------------------------------------------------------------------------------------------------------------------------
    
    func solveMaze(mazeImage: UIImage, completion: SolveMazeCompletion) {
        if let cgImage = mazeImage.cgImage {
            createColorMatrix(from: cgImage)
        } else {
            completion(false, nil)
        }
    }
    
    func createColorMatrix(from image: CGImage) {
        if let pixelData = image.dataProvider?.data {
            let bytesPerPixel: Int = image.bitsPerPixel / 8
            let pixelBytes: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            var colorMatrix: [[UIColor]] = []
            var colorRow: [UIColor]
            for y in 0..<image.height {
                colorRow = []
                for x in 0..<image.width {
                    let pixelIndex: Int = ((image.width * y) + x) * bytesPerPixel
                    let r = CGFloat(pixelBytes[pixelIndex]) / 255.0
                    let g = CGFloat(pixelBytes[pixelIndex + 1]) / 255.0
                    let b = CGFloat(pixelBytes[pixelIndex + 2]) / 255.0
                    let a = CGFloat(pixelBytes[pixelIndex + 3]) / 255.0
                    let color = UIColor(red: r, green: g, blue: b, alpha: a)
                    colorRow.append(color)
                }
                colorMatrix.append(colorRow)
            }
            print(colorMatrix.count)
            print(colorMatrix[0].count)
            let blue = colorMatrix[image.height - 5][5]
            print(blue)
            let red = colorMatrix[image.height - 5][(image.width / 2) + 7]
            print(red)
            let origin = colorMatrix[0][0] //black
            print(origin)
            let one = colorMatrix[1][1] //white
            print(one)
            print(blue == UIColor.blue)
            print(red == UIColor.red)
            print(origin == UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
            print(one == UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        }
    }
}
