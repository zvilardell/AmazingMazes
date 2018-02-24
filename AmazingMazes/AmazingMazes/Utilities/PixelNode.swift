//
//  PixelNode.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/24/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class PixelNode: NSObject {
    //the pixel matrix that we are a part of
    weak var pixelMatrix: PixelMatrix?
	//adjacent matrix nodes in pixel matrix
    var children: [PixelNode] = []
    //the PixelNode that has claimed us as an adjacent/child node
    weak var parent: PixelNode?
    //the color we represent in the pixel matrix
    var color: UIColor!
    //the CGPoint representing our location in the pixel matrix
    var point: CGPoint!
    
    init(point: CGPoint, in pixelMatrix: PixelMatrix, withColor color: UIColor) {
        self.point = point
        self.pixelMatrix = pixelMatrix
        self.color = color
    }
    
    //find and cache adjacent nodes in the pixel matrix
    func claimChildren() -> [PixelNode] {
        if children.isEmpty {
            //check for adjacent pixels above, right of, below, and left of this node
            let adjacentIndices = [
                CGPoint(x: point.x, y: point.y - 1), //above
                CGPoint(x: point.x + 1, y: point.y), //right
                CGPoint(x: point.x, y: point.y + 1), //below
                CGPoint(x: point.x - 1, y: point.y)   //left
            ]
            for pointIndex in adjacentIndices {
                if let node = pixelMatrix?[pointIndex], (node.parent == nil && node.children.isEmpty), node.color != MazeColor.black {
                    children.append(node)
                    node.parent = self
                }
            }
        }
        return children
    }
}
