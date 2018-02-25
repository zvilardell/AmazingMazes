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
    
    let imageManipulationQueue = DispatchQueue(label: "imageManipulation", qos: DispatchQoS.utility, attributes: DispatchQueue.Attributes.concurrent)
    
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
        } else if let cgImage = mazeImage.cgImage {
            //perform image manipulation on background thread
            imageManipulationQueue.async { [unowned self] in
                if let pixelHash = PixelHash(from: cgImage), let pathPoints = self.shortestPathSolutionPoints(for: pixelHash), let firstPoint = pathPoints.first {
                    let renderer = UIGraphicsImageRenderer(size: mazeImage.size)
                    let solvedMaze = renderer.image { context in
                        mazeImage.draw(at: CGPoint.zero)
                        context.cgContext.setStrokeColor(UIColor.green.cgColor)
                        context.cgContext.move(to: firstPoint)
                        context.cgContext.addLines(between: pathPoints)
                        context.cgContext.strokePath()
                    }
                    //self?.cachedSolutions[mazeImage] = solvedMaze
                    completion(true, solvedMaze)
                }
            }
        } else {
            completion(false, nil)
        }
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
