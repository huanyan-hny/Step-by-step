//
//  SecondarySettingViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/8.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class SecondarySettingViewController: UITableViewController {

    var fieldType = TextFieldType.unknown
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath == [0,0]) {
            fieldType = .dailyWalkingGoal
            performSegue(withIdentifier: "changeGoal", sender: self)
        } else {
            fieldType = .dailyRunningGoal
            performSegue(withIdentifier: "changeGoal", sender: self)
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "Daily Goal"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SettingTextFieldController {
            destination.fieldType = self.fieldType
            destination.maxTextLength = 5
        }
    }
}
