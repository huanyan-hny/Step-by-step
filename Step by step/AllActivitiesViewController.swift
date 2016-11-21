//
//  AllActivitiesViewController.swift
//  Step by step
//
//  Created by Troy on 15/11/30.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData

class AllActivitiesViewController: UITableViewController {

    // MARK: - Table view data source
    
    var managedObjectContext:NSManagedObjectContext?
    var fetchRequestController:NSFetchedResultsController<NSFetchRequestResult>?
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Run")
    
    func initFetchRequest() {
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "timestamp", cacheName: nil)
        
        do{ try fetchRequestController?.performFetch()} catch _ { print("Could not save run!")}
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchRequestController?.sections {
            return sections.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchRequestController?.sections{
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath)

        let run = fetchRequestController?.object(at: indexPath) as! Run
        let formatter = DateFormatter()
        
        formatter.dateStyle = DateFormatter.Style.full
        cell.textLabel?.text = formatter.string(from: run.timestamp! as Date)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchRequestController?.sections{
            let currentSection = sections[section]
            return currentSection.name
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Activities";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        initFetchRequest()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ActivityViewController {
            let path = self.tableView.indexPathForSelectedRow!
            let run = fetchRequestController?.object(at: path) as? Run
            destination.run = run
        }
    }
   
    
}
