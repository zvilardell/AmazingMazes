//
//  APIRequestManager.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/20/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit
import Alamofire

class APIRequestManager: NSObject {
    
    //request constants
    let baseRequestURL: String = "https://downloads-secured.bluebeam.com"
    let mazesEndpoint: String = "/homework/mazes"
    
    typealias MazesCompletion = (Bool, [Maze])->()
    
    //---------------------------------------------------------------------------------------------------------------------------
    //singleton setup
    
    static let sharedInstance = APIRequestManager()
    private override init() {
        super.init()
    }
    
    //---------------------------------------------------------------------------------------------------------------------------
    
    func getMazes(completion: @escaping MazesCompletion) {
        //request bluebeam maze data
        Alamofire.request(baseRequestURL + mazesEndpoint, method: .get).responseJSON { response in
            if let responseDict = response.result.value as? [String:Any], let mazesArray = responseDict["list"] as? [[String:String]] {
                //build array of Maze objects from response
                var mazes: [Maze] = []
                for maze in mazesArray {
                    mazes.append(Maze(mazeDict: maze))
                }
                completion(true, mazes)
            } else if let error = response.result.error {
                //an error occurred
                print(error.localizedDescription)
                completion(false, [])
            } else {
                //an unknown error occurred
                print("Unable to retrieve maze data at this time.")
                completion(false, [])
            }
        }
    }
}
