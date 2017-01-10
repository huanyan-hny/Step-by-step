//
//  RankingTableViewCell.swift
//  Step by step
//
//  Created by Troy on 2017/1/2.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!

    
    override func layoutSubviews() {
        if(Display.typeIsLike == .iphone5) {
            self.nameLabel.font = UIFont(name: "Helvetica Neue", size: 13)
            self.rankLabel.font = UIFont(name: "Helvetica Neue", size: 13)
            self.distanceLabel.font = UIFont(name: "Helvetica Neue", size: 11)
            self.dateLabel.font = UIFont(name: "Helvetica Neue", size: 11)
            self.userAvatar.layer.cornerRadius = 21.5
        } else {
            self.userAvatar.layer.cornerRadius = 25
        }
        self.userAvatar.clipsToBounds = true
        
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
