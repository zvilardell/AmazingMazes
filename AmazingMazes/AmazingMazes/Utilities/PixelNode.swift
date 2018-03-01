//
//  PixelNode.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/24/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class PixelNode: NSObject {
    
    //the pixel hash that we belong to
    weak var pixelHash: PixelHash?
    //the PixelNode that has claimed us as an adjacent/child node while solving maze
    weak var parent: PixelNode?
    //the pixel color we represent in the image
    var color: UIColor!
    //the CGPoint representing our location in the image
    var point: CGPoint!
	//adjacent pixel nodes in image
    var adjacencies: [PixelNode] {
        //return adjacent pixels above, right of, below, and left of this node
        var adjacencies: [PixelNode] = []
        let adjacentIndices = [
            CGPoint(x: point.x, y: point.y - 1), //above
            CGPoint(x: point.x + 1, y: point.y), //right
            CGPoint(x: point.x, y: point.y + 1), //below
            CGPoint(x: point.x - 1, y: point.y)   //left
        ]
        for pointIndex in adjacentIndices {
            if let node = pixelHash?[pointIndex], node.parent == nil && node != parent {
                adjacencies.append(node)
                node.parent = self
            }
        }
        return adjacencies
    }
    
    init(point: CGPoint, in pixelHash: PixelHash, withColor color: UIColor) {
        self.point = point
        self.pixelHash = pixelHash
        self.color = color
    }

}
