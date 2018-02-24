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
            imageManipulationQueue.async { [weak self] in
                if let pixelMatrix = PixelMatrix(from: cgImage), let pathPoints = self?.shortestPathSolutionPoints(for: pixelMatrix), let firstPoint = pathPoints.first {
                    UIGraphicsBeginImageContext(mazeImage.size)
                    mazeImage.draw(at: CGPoint.zero)
                    if let context = UIGraphicsGetCurrentContext() {
                        context.setStrokeColor(UIColor.green.cgColor)
                        context.move(to: firstPoint)
                        context.addLines(between: pathPoints)
                        context.strokePath()
                        if let solvedMaze: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
                            //self?.cachedSolutions[mazeImage] = solvedMaze
                            completion(true, solvedMaze)
                        } else {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    UIGraphicsEndImageContext()
                }
            }
        } else {
            completion(false, nil)
        }
    }
    
    //BFS from beginning of maze to find end
    private func shortestPathSolutionPoints(for mazeMatrix: PixelMatrix) -> [CGPoint]? {
        let nodeQueue = PixelNodeQueue()
        nodeQueue.enqueue(mazeMatrix.redPixelNode)
        while nodeQueue.count > 0 {
            if let currentNode = nodeQueue.dequeue() {
                if currentNode.color == MazeColor.blue {
                	//found end of maze
                    return getPathPoints(to: currentNode)
                }
                nodeQueue.enqueue(currentNode.claimChildren())
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
