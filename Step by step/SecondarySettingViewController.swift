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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (Display.typeIsLike == .iphone5) {
            return 37
        } else if (Display.typeIsLike == .iphone7) {
            return 45
        } else if (Display.typeIsLike == .iphone7plus) {
            return 50
        }
        return 45
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = NSLocalizedString("Daily Goal", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SettingTextFieldController {
            destination.fieldType = self.fieldType
            destination.maxTextLength = 5
        }
    }
}
