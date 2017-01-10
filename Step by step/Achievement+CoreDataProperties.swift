//
//  Achievement+CoreDataProperties.swift
//  Step by step
//
//  Created by Troy on 2017/1/9.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import Foundation
import CoreData

extension Achievement {
    @NSManaged var id: NSNumber?
    @NSManaged var date: Date?
    @NSManaged var userID: String?
    @NSManaged var isNew: NSNumber?
}
