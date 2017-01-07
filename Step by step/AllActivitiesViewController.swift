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

    // MARK: - Table view data source
    
    var managedObjectContext:NSManagedObjectContext?
    var fetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
    let dateFormatter = DateFormatter()
    var sectionHeaderHeight = CGFloat(30)
    var rowHeight = CGFloat(75)
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> String {
        if seconds >= 3600 {
            return "\(seconds/3600)h \(seconds % 3600 / 60)m \(seconds % 60)s"
        } else if seconds >= 60 {
            return "\(seconds % 3600 / 60)m \(seconds % 60)s"
        } else {
            return "\(seconds % 60)s"
        }
        
    }
    
    func initFetchRequest() {
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "date", cacheName: nil)
        fetchResultsController?.delegate = self
        do{ try fetchResultsController?.performFetch()} catch _ { print("Could not fetch run!")}
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchResultsController?.sections {
            return sections.count
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
        let displayDistance = Double(round(run.distance!.doubleValue*100)/100)
        let displayTime = secondsToHoursMinutesSeconds(seconds: run.time!.intValue)
        cell.distanceLabel.text = "\(displayDistance) miles"
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
        let city = run.city
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ActivityTableHeaderView")
        headerView?.contentView.subviews.forEach({$0.removeFromSuperview()})
        
        let dateLabel = UILabel()
        dateLabel.text = city
        dateLabel.font = UIFont(name:"Helvetica Neue", size: sectionHeaderHeight/2)
        dateLabel.textColor = UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0)
        dateLabel.sizeToFit()
        dateLabel.frame.origin.x = 10*tableView.frame.width/375
        dateLabel.frame.origin.y = (sectionHeaderHeight - dateLabel.frame.height)/2
        headerView?.contentView.addSubview(dateLabel)
        
        dateFormatter.dateFormat = "MMM d, YYYY"
        
        let locationLabel = UILabel()
        locationLabel.text = dateFormatter.string(from: date)
        locationLabel.font = UIFont(name:"Helvetica Neue", size: sectionHeaderHeight/2)
        locationLabel.textColor = UIColor(red:51.0/255.0, green:51.0/255.0, blue:51.0/255.0, alpha:1.0)
        locationLabel.sizeToFit()
        locationLabel.frame.origin.x = tableView.frame.width - locationLabel.frame.width - 10*tableView.frame.width/375
        locationLabel.frame.origin.y = (sectionHeaderHeight - locationLabel.frame.height)/2
        headerView?.contentView.addSubview(locationLabel)
        
        return headerView
    }
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle==UITableViewCellEditingStyle.delete {
            managedObjectContext?.delete(fetchResultsController?.object(at: indexPath) as! NSManagedObject)
            do{ try managedObjectContext?.save()} catch _ { print("Could not save!")}
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            configureCell(cell: tableView.cellForRow(at: indexPath! as IndexPath)! as! ActivityTableViewCell, indexPath: indexPath! as IndexPath)
        case .move:
            tableView.moveRow(at: indexPath! as IndexPath, to: newIndexPath! as IndexPath)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "Activities"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        initFetchRequest()
        tableView.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "ActivityTableHeaderView")
        dateFormatter.dateStyle = .full
        dateFormatter.locale = Locale(identifier: "en_US")
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
