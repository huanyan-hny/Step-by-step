//
//  User.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.8
//

import Foundation
import UIKit
import AWSDynamoDB

class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _name: String?
    var _signature: String?
    var _totalRunningDistance: NSNumber?
    
    class func dynamoDBTableName() -> String {

        return "stepbystep-mobilehub-138898687-User"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any] {
        return [
               "_userId" : "userId",
               "_name" : "name",
               "_signature" : "signature",
               "_totalRunningDistance" : "totalRunningDistance"
        ]
    }
}
