//
//  MazeSolver.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/23/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

//singleton class for solving mazes represented by UIImages
class MazeSolver: NSObject {
    
    //key: unsolved maze image
    //value: solved maze image, from previous solution attempt
    private var cachedSolutions: [UIImage:UIImage] = [:]
    
    //asynchronous background queue for manipulating and solving maze images
    private let imageManipulationQueue = DispatchQueue(label: "imageManipulation", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes.concurrent)
    
    typealias SolveMazeCompletion = (Bool, UIImage?)->()
    
    //---------------------------------------------------------------------------------------------------------------------------
    //singleton setup
    
    static let sharedInstance = MazeSolver()
    private override init() {
        super.init()
    }
    
    //---------------------------------------------------------------------------------------------------------------------------
    
    func solveMaze(mazeImage: UIImage, completion: @escaping SolveMazeCompletion) {
        if let solution = cachedSolutions[mazeImage] {
            //maze has already been solved, return solution
            completion(true, solution)
        } else if let cgImage = formattedCGImage(for: mazeImage) {
			//perform image manipulation and subsequent solution pathfinding on background thread
            imageManipulationQueue.async { [weak self] in
                //convert image to PixelHash and find solution path points
                if let pixelHash = PixelHash(from: cgImage), let pathPoints = self?.shortestPathSolutionPoints(for: pixelHash) {
                    //create new maze image with solution path drawn in green
                    let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: 1.0))
                    let renderer = UIGraphicsImageRenderer(size: mazeImage.size, format: format)
                    let solvedMazeImage: UIImage = renderer.image { context in
                        mazeImage.draw(at: CGPoint.zero)
                        context.cgContext.setStrokeColor(UIColor.green.cgColor)
                        context.cgContext.addLines(between: pathPoints)
                        context.cgContext.strokePath()
                    }
                    //add solution to cache
                    self?.cachedSolutions[mazeImage] = solvedMazeImage
                    DispatchQueue.main.async {
                        //return final solved maze image
                    	completion(true, solvedMazeImage)
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
    
    //Create a formatted CGImage representation of the unsolved maze image for a specific CGContext
    //(ensures that every maze image will be processed correctly when finding solution)
    private func formattedCGImage(for image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            let bitsPerComponent = 8
            let bytesPerPixel = 4
            let bytesPerRow = cgImage.width * bytesPerPixel
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
            let context = CGContext(data: nil, //allow function to automatically allocate memory for context
                                	width: cgImage.width,
                                    height: cgImage.height,
                                    bitsPerComponent: bitsPerComponent,
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
                        //found end of maze, return solution path as CGPoint array
                        return getPathPoints(to: currentNode)
                    }
                    nodeQueue.enqueue(currentNode.adjacencies)
                }
            }
        }
        return nil
    }
    
    //end of maze found, collect CGPoints representing the maze solution path
    private func getPathPoints(to endNode: PixelNode) -> [CGPoint] {
        var pathPoints: [CGPoint] = []
        var node: PixelNode? = endNode
        while node != nil {
            if let currentNode = node {
                pathPoints.append(currentNode.point)
            }
            node = node?.parent
        }
        return pathPoints
    }
}
