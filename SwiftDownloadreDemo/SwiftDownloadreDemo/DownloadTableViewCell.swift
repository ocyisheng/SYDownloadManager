//
//  DownloadTableViewCell.swift
//  SwiftDownloadreDemo
//
//  Created by gao on 2018/10/19.
//  Copyright © 2018年 gao. All rights reserved.
//

import UIKit

class DownloadTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
