//
//  SettingViewController.swift
//  Step by step
//
//  Created by Troy on 2016/12/27.
//  Copyright © 2016年 Huanyan's. All rights reserved.
//

import UIKit


class SettingViewController: UITableViewController {

    var fieldType = TextFieldType.unknown
    var maxTextLength = 15
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath == [0,0]) {
            fieldType = .username
            maxTextLength = 10
            performSegue(withIdentifier: "changeProfile", sender: self)
        } else if (indexPath == [0,1]) {
            fieldType = .signature
            maxTextLength = 15
            performSegue(withIdentifier: "changeProfile", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings";
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = UIColor.lightGray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SettingTextFieldController {
            destination.fieldType = self.fieldType
            destination.maxTextLength = self.maxTextLength
        }
    }
}
