//
//  PauseLocation+CoreDataProperties.swift
//  Step by step
//
//  Created by Troy on 2017/1/5.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import Foundation
import CoreData

extension PauseLocation {
    
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timestamp: Date?
    @NSManaged var run: NSManagedObject?
    
}
