//
//  AllRankingsViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/2.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData

class AllRankingsViewController: UITableViewController {

    var rowHeight = CGFloat(75)
    var managedObjectContext:NSManagedObjectContext?
    var fetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    
    
    func displayEmptyMessage() {
        let messageLabel = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.size.width,height:self.view.bounds.size.height))
        messageLabel.text = "You don't have any ranking history yet"
        messageLabel.textColor = Colors.myTextGray
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
        let count = fetchResultsController!.fetchedObjects!.count
        if count == 0 {
            displayEmptyMessage()
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableViewCell", for: indexPath) as! RankingTableViewCell
        let ranking = fetchResultsController?.object(at: indexPath) as! Ranking
        let displayDistance = Double(round(ranking.totalDistance!.doubleValue*100)/100)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en-US")
        let displayDate = dateFormatter.string(from: ranking.startDate!) + " - " + dateFormatter.string(from: ranking.endDate!)
        let displayRanking = ranking.type! + " ranking: \(ranking.rank!)"
        
        cell.nameLabel.text = UserDefaults.standard.string(forKey: "username")
        cell.distanceLabel.text = "\(displayDistance) miles"
        cell.rankLabel.text = displayRanking
        cell.dateLabel.text = displayDate
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let avatarPath = documentPath.appendingPathComponent("userAvatar.png")
        
        if let avatar = UIImage(contentsOfFile:avatarPath.path) {
            cell.userAvatar.image = avatar
        }
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do{ try fetchResultsController?.performFetch()} catch _ { print("Could not fetch ranking!")}
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Rankings"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.tableView.tableFooterView = UIView()
        if (Display.typeIsLike == .iphone5) {
            rowHeight = 64
        }
    }
    
}
