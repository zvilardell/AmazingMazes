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

    override func viewDidLoad() {
        super.viewDidLoad()
        //don't display empty table cells below data
        mazesTableView.tableFooterView = UIView(frame: CGRect.zero)
        //retrieve maze data from bluebeam server
        loadMazeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mazes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate

extension MazesViewController: UITableViewDelegate {
    
}
