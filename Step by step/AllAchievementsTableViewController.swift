//
//  AllAchievementsTableViewController.swift
//  Step by step
//
//  Created by Troy on 2017/1/2.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import UIKit
import CoreData

class AllAchievementsTableViewController: UITableViewController {

    var sectionHeaderHeight = CGFloat(20)
    var rowHeight = CGFloat(75)
    var managedObjectContext:NSManagedObjectContext?
    var fetchResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    var newAchievementIds = [Int]()
    var achieved = [Int:Bool]()
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
 
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rankCell = cell as! AchievementTableViewCell
        if (achieved[indexPath.section]!) {
            rankCell.achievementMedal.image = #imageLiteral(resourceName: "medal")
        }
    }
    
    
    func updateAchievements() {
        for i in 0...8 {
            achieved[i] = false
        }
        for object in fetchResultsController!.fetchedObjects! {
            if let achievement = object as? Achievement {
                if achievement.isNew!.boolValue {
                    newAchievementIds.append(achievement.id!.intValue)
                    achievement.isNew = 0
                    do{ try managedObjectContext!.save()} catch _ { print("Could not save!")}
                } else {
                    achieved[achievement.id!.intValue] = true
                }
            }
        }
    }
   
    func animateNewAchievement() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            for newId in self.newAchievementIds {
                let cell = self.tableView.cellForRow(at: [newId,0]) as! AchievementTableViewCell
                cell.achievementMedal.image = #imageLiteral(resourceName: "medal")
                
                UIView.animate(withDuration: 0.5, animations: {
                    cell.achievementMedal.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: { (finish: Bool) in
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.achievementMedal.transform = CGAffineTransform.identity
                    })
                })
                
                UIView.animate(withDuration: 1, animations: {
                    cell.check.alpha = 1
                })
            }
            
        })
        tableView.isScrollEnabled = true
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if (!newAchievementIds.isEmpty){
            animateNewAchievement()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do{ try fetchResultsController?.performFetch()} catch _ { print("Could not fetch ranking!")}
        updateAchievements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!newAchievementIds.isEmpty) {
            tableView.isScrollEnabled = false
            self.tableView.scrollToRow(at: [newAchievementIds[0],0], at: .top, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Achievements"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.tableView.tableFooterView = UIView()
        if (Display.typeIsLike == .iphone5) {
            sectionHeaderHeight = CGFloat(17)
            rowHeight = CGFloat(64)
        }
        
    }

}
