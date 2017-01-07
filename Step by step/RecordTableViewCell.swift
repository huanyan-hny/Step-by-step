//
//  RecordTableViewCell.swift
//  Step by step
//
//  Created by Troy on 2017/1/3.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var recordDetail: UILabel!
    @IBOutlet weak var recordName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
