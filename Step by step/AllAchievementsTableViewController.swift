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
    var newAchievementId = -1
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
 
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    
    func updateAchievements() {
        for object in fetchResultsController!.fetchedObjects! {
            if let achievement = object as? Achievement {
                if achievement.isNew!.boolValue {
                    newAchievementId = achievement.id!.intValue
                    achievement.isNew = 0
                    do{ try managedObjectContext!.save()} catch _ { print("Could not save!")}
                } else {
                    let cell = tableView.cellForRow(at: [achievement.id!.intValue-1,0]) as!AchievementTableViewCell
                    cell.achievementMedal.image = #imageLiteral(resourceName: "medal")
                }
            }
        }
    }
   
    func animateNewAchievement() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            let cell = self.tableView.cellForRow(at: [self.newAchievementId-1,0]) as! AchievementTableViewCell
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
        })
        tableView.isScrollEnabled = true
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if (newAchievementId != -1){
            animateNewAchievement()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateAchievements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (newAchievementId != -1) {
            tableView.isScrollEnabled = false
            self.tableView.scrollToRow(at: [newAchievementId-1,0], at: .middle, animated: true)
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
