//
//  StepsRecord.swift
//  Step by step
//
//  Created by Troy on 15/5/20.
//  Copyright (c) 2015年 Huanyan's. All rights reserved.
//

import Foundation
import CoreMotion

class MainActivity{

    
    let pedometer = CMPedometer()
    let today = Date()
    
    var steps:Int
    var distance:Int
    var calorie:Double
    
    init()
    {
        steps = 0
        distance = 0
        calorie = 0
        pedometer.startUpdates(from: Calendar.current.startOfDay(for: Date()), withHandler:{data, error in
            if (error==nil) {
            self.steps = Int(data!.numberOfSteps.int32Value)
            self.distance = Int(data!.distance!.int32Value)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "steps"), object: self)
            }
            })
    }
    
}
