//
//  Time.swift
//  Step by step
//
//  Created by Troy on 2017/1/9.
//  Copyright © 2017年 Huanyan's. All rights reserved.
//

import Foundation

class Time {
    
    static func secondsFormatted(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        if hours>10 {
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        } else if hours>0 {
            return String(format:"%01i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format:"%02i:%02i",minutes, seconds)
        }
    }
    
    static func secondsFormattedString(seconds: Int) -> String {
        if seconds >= 3600 {
            return "\(seconds/3600)h \(seconds % 3600 / 60)m \(seconds % 60)s"
        } else if seconds >= 60 {
            return "\(seconds % 3600 / 60)m \(seconds % 60)s"
        } else {
            return "\(seconds % 60)s"
        }
        
    }
}
