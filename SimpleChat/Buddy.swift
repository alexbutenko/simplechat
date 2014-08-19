//
//  Buddy.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation
import CoreData

@objc(Buddy)
class Buddy : NSManagedObject {
    @NSManaged var name:String
    @NSManaged var serverID:String //refer to ID of iCloud user, not record at CloudKit
    @NSManaged var messages:NSSet
}