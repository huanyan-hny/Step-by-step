//
//  AllRecordsTableViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/3.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData

class AllRecordsTableViewController: UITableViewController {

    var sectionHeaderHeight = CGFloat(30)
    var rowHeight = CGFloat(75)
    var managedObjectContext:NSManagedObjectContext?
    var fetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    
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
    
    func updateRecords() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM D, YYYY"
        for object in fetchResultsController!.fetchedObjects! {
            let record = object as! Record
            if let type = record.type {
                switch type {
                case "Distance":
                    let cell = tableView.cellForRow(at: [0,0]) as! RecordTableViewCell
                    cell.recordTime.text = dateFormatter.string(from: record.date!)
                    cell.recordDetail.text = String(format: "%.1f miles", record.value!.doubleValue)
                case "Pace":
                    let cell = tableView.cellForRow(at: [0,1]) as! RecordTableViewCell
                    cell.recordTime.text = dateFormatter.string(from: record.date!)
                    cell.recordDetail.text = Time.secondsFormatted(seconds: record.value!.intValue) + "/mi"
                case "Duration":
                    let cell = tableView.cellForRow(at: [0,2]) as! RecordTableViewCell
                    cell.recordTime.text = dateFormatter.string(from: record.date!)
                    cell.recordDetail.text = Time.secondsFormattedString(seconds: record.value!.intValue)
                case "Steps":
                    let cell = tableView.cellForRow(at: [1,0]) as! RecordTableViewCell
                    cell.recordTime.text = dateFormatter.string(from: record.date!)
                    cell.recordDetail.text = record.value!.stringValue
                default:
                    break
                }
            }

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateRecords()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Personal Records"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.tableView.tableFooterView = UIView()

        if (Display.typeIsLike == .iphone5) {
            sectionHeaderHeight = CGFloat(26)
            rowHeight = CGFloat(64)
        }
    }
}
