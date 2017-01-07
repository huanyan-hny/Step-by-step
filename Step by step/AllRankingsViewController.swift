//
//  AllRankingsViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/2.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit

class AllRankingsViewController: UITableViewController {

    var rowHeight = CGFloat(75)
    
    func displayEmptyMessage() {
        let messageLabel = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.size.width,height:self.view.bounds.size.height))
        messageLabel.text = "You don't have any ranking history yet"
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableViewCell", for: indexPath) as! RankingTableViewCell
        if (indexPath.row == 0) {
            cell.userAvatar.image = #imageLiteral(resourceName: "chenyao")
            cell.nameLabel.text = "陈垚"
            cell.distanceLabel.text = "26 miles"
            cell.rankLabel.text = "Weekly: 17"
            cell.timeLabel.text = "Jan 2, 2016 - Jan 9, 2016"
        } else if (indexPath.row == 1) {
            cell.userAvatar.image = #imageLiteral(resourceName: "chenyao")
            cell.nameLabel.text = "陈垚"
            cell.distanceLabel.text = "143 miles"
            cell.rankLabel.text = "Monthly: 3"
            cell.timeLabel.text = "December, 2015"
        } else if (indexPath.row == 2) {
            cell.userAvatar.image = #imageLiteral(resourceName: "chenyao")
            cell.nameLabel.text = "陈垚"
            cell.distanceLabel.text = "23 miles"
            cell.rankLabel.text = "Weekly: 25"
            cell.timeLabel.text = "Dec 25, 2015 - Jan 1, 2016"
        } else {
            cell.userAvatar.image = #imageLiteral(resourceName: "chenyao")
            cell.nameLabel.text = "陈垚"
            cell.distanceLabel.text = "29 miles"
            cell.rankLabel.text = "Weekly: 1"
            cell.timeLabel.text = "Dec 17, 2015 - Dec 24, 2016"
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Rankings"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.tableView.tableFooterView = UIView()
        if (Display.typeIsLike == .iphone5) {
            rowHeight = 64
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
