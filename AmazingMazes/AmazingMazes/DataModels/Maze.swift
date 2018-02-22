//
//  Maze.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/21/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import Foundation

struct Maze {
    var name: String!
    var description: String!
    var imageURL: URL!
    
    init(mazeDict: [String:String]) {
        //initialize Maze object from data dictionary
        name = mazeDict["name"] ?? ""
        description = mazeDict["description"] ?? ""
        if let urlString = mazeDict["url"] {
        	imageURL = URL(string: urlString)
        }
    }
}
