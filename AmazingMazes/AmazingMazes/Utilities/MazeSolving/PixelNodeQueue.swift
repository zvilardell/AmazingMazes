//
//  PixelQueue.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/24/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

//queue data structure used in BFS for maze solution path
class PixelNodeQueue: NSObject {
    
    private var queue: [PixelNode] = []
    
    var count: Int {
        return queue.count
    }
    
    func enqueue(_ node: PixelNode) {
        queue.append(node)
    }
    
    func enqueue(_ nodes: [PixelNode]) {
        queue.append(contentsOf: nodes)
    }
    
    func dequeue() -> PixelNode? {
        //ensure that the queue is populated before dequeueing
        return queue.count > 0 ? queue.removeFirst() : nil
    }
}
