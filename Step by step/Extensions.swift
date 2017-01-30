//
//  Extentions.swift
//  Step by step
//
//  Created by Troy on 2017/1/15.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import Foundation
import CoreData

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension StepsViewController {
    func updateStepsAchievements(id:Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Achievement")
        let userID = UserDefaults.standard.string(forKey: "userID")!
        fetchRequest.predicate = NSPredicate(format: "id = %@ AND userID = %@",id as NSNumber, userID as NSString)
        do {
            let records = try managedObjectContext!.fetch(fetchRequest) as! [Achievement]
            if (records.isEmpty) {
                let savedAchievement = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into:managedObjectContext!) as! Achievement
                savedAchievement.userID = userID
                savedAchievement.id = id as NSNumber?
                savedAchievement.isNew = 1
                savedAchievement.date = Date()
                savedAchievement.synchronized = 0
                
                do{ try managedObjectContext!.save()} catch _ { print("Could not save achievement!")}
            }
        } catch _ {}
    }
    
    func updateStepsRecord(steps:Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        let userID = UserDefaults.standard.string(forKey: "userID")!
        fetchRequest.predicate = NSPredicate(format: "type = %@ AND userID = %@","Steps",userID as NSString)
        do {
            let records = try managedObjectContext?.fetch(fetchRequest) as! [Record]
            if (records.isEmpty) {
                let savedRecord = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
                savedRecord.userID = userID
                savedRecord.date = Date()
                savedRecord.type = "Steps"
                savedRecord.value = steps as NSNumber?
                savedRecord.synchronized = 0
            } else {
                let stepsRecord = records.first!
                if (stepsRecord.value!.intValue < steps) {
                    stepsRecord.value = steps as NSNumber?
                    stepsRecord.date = Date()
                }
            }
            try managedObjectContext?.save()
        } catch _ {}
    }

}

extension RankingViewController {
    func updateRankingAchievement(id:Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Achievement")
        let userID = UserDefaults.standard.string(forKey: "userID")!
        fetchRequest.predicate = NSPredicate(format: "id = %@ AND userID = %@", id as NSNumber, userID as NSString)
        do {
            let records = try managedObjectContext!.fetch(fetchRequest) as! [Achievement]
            if (records.isEmpty) {
                let savedAchievement = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into:managedObjectContext!) as! Achievement
                savedAchievement.userID = UserDefaults.standard.string(forKey: "userID")
                savedAchievement.id = id as NSNumber?
                savedAchievement.isNew = 1
                savedAchievement.date = Date()
                savedAchievement.synchronized = 0
                
                do{ try managedObjectContext!.save()} catch _ { print("Could not save achievement!")}
            }
        } catch _ {}
    }
}

extension RunningResultViewController {
    func updateRunAchievement(id:Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Achievement")
        let userID = UserDefaults.standard.string(forKey: "userID")!
        fetchRequest.predicate = NSPredicate(format: "id = %d AND userID = %@", id as NSNumber, userID as NSString)
        do {
            let records = try managedObjectContext!.fetch(fetchRequest) as! [Achievement]
            if (records.isEmpty) {
                let savedAchievement = NSEntityDescription.insertNewObject(forEntityName: "Achievement", into:managedObjectContext!) as! Achievement
                savedAchievement.userID = UserDefaults.standard.string(forKey: "userID")
                savedAchievement.id = id as NSNumber?
                savedAchievement.isNew = 1
                savedAchievement.date = Date()
                savedAchievement.synchronized = 0
                
                do{ try managedObjectContext!.save()} catch _ { print("Could not save achievement!")}
            }
        } catch _ {}
    }
    
    func updateRunRecord(run:Run) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        let userID = UserDefaults.standard.string(forKey: "userID")!
        fetchRequest.predicate = NSPredicate(format: "type = %@ AND userID = %@","Distance", userID as NSString)
        do {
            let records = try managedObjectContext?.fetch(fetchRequest) as! [Record]
            if (records.isEmpty) {
                let savedRecord = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
                savedRecord.userID = UserDefaults.standard.string(forKey: "userID")
                savedRecord.date = Date()
                savedRecord.type = "Distance"
                savedRecord.value = run.distance as NSNumber?
                savedRecord.synchronized = 0
            } else {
                let distanceRecord = records.first!
                if (distanceRecord.value!.doubleValue < run.distance!.doubleValue) {
                    distanceRecord.value = run.distance
                    distanceRecord.date = Date()
                }
            }
            try managedObjectContext?.save()
        } catch _ {}
        
        fetchRequest.predicate = NSPredicate(format: "type = %@ AND userID = %@","Duration", userID as NSString)
        do {
            let records = try managedObjectContext?.fetch(fetchRequest) as! [Record]
            if (records.isEmpty) {
                let savedRecord = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
                savedRecord.userID = UserDefaults.standard.string(forKey: "userID")
                savedRecord.date = Date()
                savedRecord.type = "Duration"
                savedRecord.value = run.time as NSNumber?
                savedRecord.synchronized = 0
            } else {
                let durationRecord = records.first!
                if (durationRecord.value!.intValue < run.time!.intValue) {
                    durationRecord.value = run.time
                    durationRecord.date = Date()
                }
               
            }
            try managedObjectContext?.save()
        } catch _ {}
        
        fetchRequest.predicate = NSPredicate(format: "type = %@ AND userID = %@","Pace", userID as NSString)
        do {
            let records = try managedObjectContext?.fetch(fetchRequest) as! [Record]
            if (records.isEmpty) {
                let savedRecord = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext!) as! Record
                savedRecord.userID = UserDefaults.standard.string(forKey: "userID")
                savedRecord.date = Date()
                savedRecord.type = "Pace"
                savedRecord.value = run.pace as NSNumber?
                savedRecord.synchronized = 0
            } else {
                let paceRecord = records.first!
                if (run.pace!.intValue>0 && (paceRecord.value == 0 || paceRecord.value!.intValue > run.pace!.intValue)) {
                    paceRecord.value = run.pace
                    paceRecord.date = Date()
                }
                
            }
            try managedObjectContext?.save()
        } catch _ {}

    }
}

