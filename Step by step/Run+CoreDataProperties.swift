//
//  Run+CoreDataProperties.swift
//  Step by step
//
//  Created by Troy on 15/10/28.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Run {
    @NSManaged var userID: String?
    @NSManaged var distance: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var pace: NSNumber?
    @NSManaged var energy: NSNumber?
    @NSManaged var notes: String?
    @NSManaged var date: Date?
    @NSManaged var weather: String?
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var address: String?
    @NSManaged var locations: NSOrderedSet?
    @NSManaged var pausedLocations: NSOrderedSet?
    @NSManaged var synchronized: NSNumber?
}
