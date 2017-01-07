//
//  Location+CoreDataProperties.swift
//  Step by step
//
//  Created by Troy on 15/10/28.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timestamp: Date?
    @NSManaged var run: NSManagedObject?

}
