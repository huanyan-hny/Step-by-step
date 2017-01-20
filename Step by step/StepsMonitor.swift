//
//  StepsRecord.swift
//  Step by step
//
//  Created by Troy on 15/5/20.
//  Copyright (c) 2015年 Huanyan's. All rights reserved.
//

import Foundation
import CoreMotion

class StepsMonitor{

    
    let pedometer = Pedometer.sharedInstance
    let today = Date()
    
    var steps = 0
    var distance = 0.0
    var calorie = 0
    var lift = 0
    
    init()
    {
        pedometer.startUpdates(from: Calendar.current.startOfDay(for: Date()), withHandler:{data, error in
            if (error==nil) {
                self.steps = Int(data!.numberOfSteps.intValue)
                self.distance = Double(round((data!.distance!.doubleValue/1000)*10)/10)
                self.calorie = Int(70*data!.distance!.doubleValue*1.036/1000)
                self.lift = data!.floorsAscended!.intValue
                NotificationCenter.default.post(name: Notification.Name(rawValue: "steps"), object: self)
            }   
        })
    }
    
    func refresh() {
        pedometer.stopUpdates()
        pedometer.startUpdates(from: Calendar.current.startOfDay(for: Date()), withHandler:{data, error in
            if (error==nil) {
                self.steps = Int(data!.numberOfSteps.intValue)
                self.distance = Double(round((data!.distance!.doubleValue/1000)*10)/10)
                self.calorie = Int(70*data!.distance!.doubleValue*1.036/1000)
                self.lift = data!.floorsAscended!.intValue
                NotificationCenter.default.post(name: Notification.Name(rawValue: "steps"), object: self)
            }
        })
    }
    
}
