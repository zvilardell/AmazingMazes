//
//  MazeSolutionViewController.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/22/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit
import ImageScrollView

class MazeSolutionViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var solvedMazeImageScrollView: ImageScrollView!
    
    //set from MazesViewController on maze selection
    var mazeImage: UIImage!
    var mazeName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        //set page title
        navigationItem.title = "\(mazeName ?? "") Solution"
        //solve selected maze
        solveMaze()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func solveMaze() {
        //pass maze image to maze solver
        if let maze = mazeImage {
            MazeSolver.sharedInstance.solveMaze(mazeImage: maze) {[weak self] success, image in
                self?.activityIndicator.stopAnimating()
                if success, let solvedImage = image {
                    //display solved maze image with double tap / pinch to zoom functionality
                    self?.solvedMazeImageScrollView.display(image: solvedImage)
                } else {
                    //something went wrong, show alert
                    let alert = UIAlertController(title: "Error", message: "Unable to solve maze.", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { _ in
                        //navigate back to mazes
                        self?.navigationController?.popViewController(animated: true)
                    }
                    alert.addAction(okAction)
                    self?.present(alert, animated: true)
                }
            }
        }
    }

}
