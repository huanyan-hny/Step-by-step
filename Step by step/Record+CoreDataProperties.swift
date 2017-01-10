//
//  Record+CoreDataProperties.swift
//  Step by step
//
//  Created by Troy on 2017/1/9.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import Foundation
import CoreData

extension Record {
    @NSManaged var userID: String?
    @NSManaged var value: NSNumber?
    @NSManaged var type: String?
    @NSManaged var date: Date?
    
}
