//
//  MazeSolutionViewController.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/22/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class MazeSolutionViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //set from MazesViewController on maze selection
    var mazeImage: UIImage!
    var mazeName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        //set page title
        navigationItem.title = "\(mazeName ?? "") Solution"
        //pass maze image to maze solver
        if let maze = mazeImage {
            MazeSolver.sharedInstance.solveMaze(mazeImage: maze) {success, image in
                if success, let solvedImage = image {
                    
                } else {
                    print("nope")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
