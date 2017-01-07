//
//  RankingCellView.swift
//  Step by step
//
//  Created by Troy on 2016/12/9.
//  Copyright © 2016年 Huanyan's. All rights reserved.
//

import UIKit

class RankingViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var ranking: UILabel!
    @IBOutlet weak var signature: UILabel!
    
    override func layoutSubviews() {
        if(Display.typeIsLike == .iphone5) {
            self.name.font = UIFont(name: "Helvetica Neue", size: 13)
            self.ranking.font = UIFont(name: "Helvetica Neue", size: 12)
            self.signature.font = UIFont(name: "Helvetica Neue", size: 11)
            self.avatar.layer.cornerRadius = 21.5
        } else {
            self.avatar.layer.cornerRadius = 25
        }
        self.avatar.clipsToBounds = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
