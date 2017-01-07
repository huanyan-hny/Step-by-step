//
//  ActivityTableViewCell.swift
//  Step by step
//
//  Created by Troy on 15/11/30.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    
    override func layoutSubviews() {
        if (Display.typeIsLike == .iphone5) {
            distanceLabel.font = UIFont(name: "Helvetica Neue", size: 13)
            timeLabel.font = UIFont(name: "Helvetica Neue", size: 11)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
