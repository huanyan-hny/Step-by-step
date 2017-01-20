//
//  Ranking+CoreDataProperties.swift
//  Step by step
//
//  Created by Troy on 2017/1/9.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import Foundation
import CoreData

extension Ranking {
    
    @NSManaged var userID: String?
    @NSManaged var rank: NSNumber?
    @NSManaged var type: String?
    @NSManaged var totalDistance: NSNumber?
    @NSManaged var startDate: Date?
    @NSManaged var endDate: Date?
    @NSManaged var synchronized: NSNumber?
    @NSManaged var week: NSNumber?
    @NSManaged var month: NSNumber?
}
