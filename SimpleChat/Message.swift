//
//  Message.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation
import CoreData

@objc(Message)
class Message : NSManagedObject {
    @NSManaged var value:String
    @NSManaged var serverID:String
    @NSManaged var date:NSDate
    @NSManaged var owner:Buddy
}