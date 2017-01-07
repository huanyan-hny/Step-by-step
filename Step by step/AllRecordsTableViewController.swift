//
//  AllRecordsTableViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/3.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class AllRecordsTableViewController: UITableViewController {

    var sectionHeaderHeight = CGFloat(30)
    var rowHeight = CGFloat(75)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0)
        headerView.textLabel?.font = UIFont(name:"Helvetica Neue", size: sectionHeaderHeight/2)
        if (section==0) {
            headerView.textLabel?.text = "Running"
        } else {
            headerView.textLabel?.text = "Walking"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Personal Records"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.tableView.tableFooterView = UIView()
        tableView.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "RecordTableHeaderView")
        if (Display.typeIsLike == .iphone5) {
            sectionHeaderHeight = CGFloat(26)
            rowHeight = CGFloat(64)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
