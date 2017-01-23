//
//  AllActivitiesViewController.swift
//  Step by step
//
//  Created by Troy on 15/11/30.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData

class AllActivitiesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext:NSManagedObjectContext?
    var fetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var sectionHeaderHeight = CGFloat(30)
    var rowHeight = CGFloat(75)
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
    let dateFormatter = DateFormatter()
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    
    func displayEmptyMessage() {
        let messageLabel = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.size.width,height:self.view.bounds.size.height))
        messageLabel.text = NSLocalizedString("No running", comment: "")
        messageLabel.textColor = Colors.myTextGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let count = fetchResultsController?.sections?.count {
            if (count == 0) {
                displayEmptyMessage()
            } else {
                return count
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchResultsController?.sections{
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func configureCell(cell: ActivityTableViewCell, indexPath: IndexPath) {
        let run = fetchResultsController?.object(at: indexPath) as! Run
        let displayDistance:String
        let displayTime = Time.secondsFormattedString(seconds: run.time!.intValue)
        if (language == "zh_Hans") {
            displayDistance = String(format:"%.1f", Double(round(run.distance!.doubleValue*10)/10))
            cell.distanceLabel.text = "\(displayDistance) 公里"
        } else {
            displayDistance = String(format:"%.1f", Double(round((run.distance!.doubleValue/1.60934)*10)/10))
            cell.distanceLabel.text = "\(displayDistance) miles"
        }
        
        cell.timeLabel.text = displayTime
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as!ActivityTableViewCell

        configureCell(cell: cell,indexPath: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let indexPath = IndexPath(row: 0, section: section)
        let run = fetchResultsController?.object(at: indexPath) as! Run
        
        let date = run.date!
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ActivityTableHeaderView")
        headerView?.contentView.subviews.forEach({$0.removeFromSuperview()})
        
        let locationLabel = UILabel()
        locationLabel.text = run.city

        locationLabel.font = UIFont(name:"Helvetica Neue", size: sectionHeaderHeight/2)
        locationLabel.textColor = UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0)
        locationLabel.sizeToFit()
        locationLabel.frame.origin.x = 10*tableView.frame.width/375
        locationLabel.frame.origin.y = (sectionHeaderHeight - locationLabel.frame.height)/2
        headerView?.contentView.addSubview(locationLabel)
        
        let dateLabel = UILabel()
        dateLabel.text = dateFormatter.string(from: date)
        dateLabel.font = UIFont(name:"Helvetica Neue", size: sectionHeaderHeight/2)
        dateLabel.textColor = UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0)
        dateLabel.sizeToFit()
        dateLabel.frame.origin.x = tableView.frame.width - dateLabel.frame.width - 10*tableView.frame.width/375
        dateLabel.frame.origin.y = (sectionHeaderHeight - dateLabel.frame.height)/2
        headerView?.contentView.addSubview(dateLabel)
        
        return headerView
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle==UITableViewCellEditingStyle.delete {
            managedObjectContext?.delete(fetchResultsController?.object(at: indexPath) as! NSManagedObject)
            do{ try managedObjectContext?.save()} catch _ { print("Could not save!")}
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do{ try fetchResultsController?.performFetch()} catch _ { print("Could not fetch run!")}
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = NSLocalizedString("Run", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        dateFormatter.dateStyle = .medium
        tableView.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "ActivityTableHeaderView")
        if (Display.typeIsLike == .iphone5) {
            sectionHeaderHeight = CGFloat(26)
            rowHeight = CGFloat(64)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ActivityViewController {
            let path = self.tableView.indexPathForSelectedRow!
            let run = fetchResultsController?.object(at: path) as? Run
            destination.run = run
            destination.managedObjectContext = managedObjectContext
        }
    }
   
    
}
