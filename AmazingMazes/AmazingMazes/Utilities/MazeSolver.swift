//
//  MazeSolver.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/23/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

//singleton class that solves mazes contained in UIImages
class MazeSolver: NSObject {
    
    //key: unsolved maze image
    //value: solved maze image, from previous solution attempt
    private var cachedSolutions: [UIImage:UIImage] = [:]
    
    typealias SolveMazeCompletion = (Bool, UIImage?)->()
    
    private let imageManipulationQueue = DispatchQueue(label: "imageManipulation", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes.concurrent)
    private let pathfindingQueue = DispatchQueue(label: "pathfinding", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes.concurrent)
    
    //---------------------------------------------------------------------------------------------------------------------------
    //singleton setup
    
    static let sharedInstance = MazeSolver()
    private override init() {
        super.init()
    }
    
    //---------------------------------------------------------------------------------------------------------------------------
    
    func solveMaze(mazeImage: UIImage, completion: @escaping SolveMazeCompletion) {
        if let solution = cachedSolutions[mazeImage] {
            completion(true, solution)
        } else if let cgImage = formattedCGImage(for: mazeImage) {
			//perform image manipulation on background thread
            imageManipulationQueue.async { [weak self] in
                if let pixelHash = PixelHash(from: cgImage), let pathPoints = self?.shortestPathSolutionPoints(for: pixelHash), let firstPoint = pathPoints.first {
                    let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: 1.0))
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: cgImage.width, height: cgImage.height), format: format)
                    let solvedMaze = renderer.image { context in
                        mazeImage.draw(at: CGPoint.zero)
                        context.cgContext.setStrokeColor(UIColor.green.cgColor)
                        context.cgContext.move(to: firstPoint)
                        context.cgContext.addLines(between: pathPoints)
                        context.cgContext.strokePath()
                    }
                    self?.cachedSolutions[mazeImage] = solvedMaze
                    DispatchQueue.main.async {
                    	completion(true, solvedMaze)
                    }
                } else {
                    DispatchQueue.main.async {
                    	completion(false, nil)
                    }
                }
            }
        } else {
            completion(false, nil)
        }
    }
    
    func formattedCGImage(for image: UIImage) -> CGImage? {
        //ensure that any maze image can be processed correctly by creating a formatted CGImage representation for a specific CGContext
        if let cgImage = image.cgImage {
            let bytesPerRow = cgImage.width * 4
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
            let context = CGContext(data: nil,
                                	width: cgImage.width,
                                    height: cgImage.height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo.rawValue)
            let rect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
            context?.draw(cgImage, in: rect)
            let formattedImage = context?.makeImage()
            return formattedImage
        }
        return nil
    }
    
    //BFS from beginning of maze to find end
    private func shortestPathSolutionPoints(for pixelHash: PixelHash) -> [CGPoint]? {
        if let rootPoint = pixelHash.redPixelPoint, let rootNode = pixelHash[rootPoint] {
            let nodeQueue = PixelNodeQueue()
            nodeQueue.enqueue(rootNode)
            while nodeQueue.count > 0 {
                if let currentNode = nodeQueue.dequeue() {
                    if currentNode.color == MazeColor.blue {
                        //found end of maze
                        return getPathPoints(to: currentNode)
                    }
                    nodeQueue.enqueue(currentNode.adjacencies)
                }
            }
        }
        return nil
    }
    
    private func getPathPoints(to endNode: PixelNode) -> [CGPoint] {
        var pathPoints: [CGPoint] = []
        var node: PixelNode? = endNode
        while node != nil {
            if let currentNode = node {
                pathPoints.insert(currentNode.point, at: 0)
            }
            node = node?.parent
        }
        return pathPoints
    }
}
