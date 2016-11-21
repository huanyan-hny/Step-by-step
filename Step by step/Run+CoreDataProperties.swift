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

    @NSManaged var distance: NSNumber?
    @NSManaged var duration: NSNumber?
    @NSManaged var timestamp: Date?
    @NSManaged var locations: NSOrderedSet?

}
