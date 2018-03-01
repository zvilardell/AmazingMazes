//
//  MazesViewController.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/21/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit

class MazesViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mazesTableView: UITableView!
    
    //mazes to display in table view
    var mazes: [Maze] = []
    
    //height value for table view cells
    var cellHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        //don't display empty table cells below data
        mazesTableView.tableFooterView = UIView(frame: CGRect.zero)
        //calculate and set cellHeight
        setCellHeight()
        //retrieve maze data
        loadMazeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCellHeight() {
        //calculate cell height based on screen width
        let screenWidth = UIScreen.main.bounds.width
        //cell is 20% taller than it is wide
        cellHeight = screenWidth * 1.2
    }
    
    func loadMazeData() {
        APIRequestManager.sharedInstance.getMazes() {[weak self] success, mazes in
            self?.activityIndicator.stopAnimating()
            if success {
                //reload table view with maze content
                self?.mazes.append(contentsOf: mazes)
                self?.mazesTableView.reloadData()
            } else {
                //something went wrong, show alert
                let alert = UIAlertController(title: "Error", message: "Unable to retrieve maze data at this time.", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
                let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) { _ in
                    //initiate another request for maze data
                    self?.activityIndicator.startAnimating()
                    self?.loadMazeData()
                }
                alert.addAction(retryAction)
                alert.addAction(cancelAction)
                self?.present(alert, animated: true)
            }
        }
    }
}

//MARK: UITableViewDataSource

extension MazesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mazes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MazeTableViewCell.reuseIdentifier, for: indexPath) as? MazeTableViewCell {
            cell.setup(maze: mazes[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate

extension MazesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //present MazeSolutionViewController for the selected maze
        //(NOTE: I rarely use storyboard segues anymore as I've found them too rigid/cumbersome in larger projects)
        let selectedMaze = mazes[indexPath.row]
        if let solutionVC = storyboard?.instantiateViewController(withIdentifier: "MazeSolutionViewController") as? MazeSolutionViewController,
        let selectedCell = tableView.cellForRow(at: indexPath) as? MazeTableViewCell,
        let selectedMazeImage = selectedCell.mazeImageView.image { //grab downloaded image from cell's UIImageView
            solutionVC.mazeName = selectedMaze.name
            solutionVC.mazeImage = selectedMazeImage
            navigationController?.pushViewController(solutionVC, animated: true)
        }
    }
}
