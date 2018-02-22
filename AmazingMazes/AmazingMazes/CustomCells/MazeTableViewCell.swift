//
//  MazeTableViewCell.swift
//  AmazingMazes
//
//  Created by Zach Vilardell on 2/22/18.
//  Copyright © 2018 zvilardell. All rights reserved.
//

import UIKit
import SDWebImage

class MazeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mazeImageView: UIImageView!
    @IBOutlet weak var mazeNameLabel: UILabel!
    @IBOutlet weak var mazeDescriptionLabel: UILabel!
    
    static let reuseIdentifier: String = "MazeTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setup(maze: Maze) {
        //configure cell elements with maze data
        mazeNameLabel.text = maze.name
        mazeDescriptionLabel.text = maze.description
        mazeImageView.sd_setImage(with: maze.imageURL)
    }

}
