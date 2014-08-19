//
//  BuddyDataManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class SenderBuddyDataManager {
    
    struct SingleInstance {
        static let sharedUserDataManager: SenderBuddyDataManager = {
            let userDataManager = SenderBuddyDataManager()
            
            return userDataManager
            }()
    }
    
    class var sharedInstance: SenderBuddyDataManager {
        return SingleInstance.sharedUserDataManager
    }
    
    var persistedBuddy:Buddy?
    
    func setupWithBuddy(buddy:BuddyPlainObject) {
        //check persisted current user
        
        persistedBuddy = Buddy.MR_findFirstByAttribute("serverID", withValue: buddy.serverID) as? Buddy
        
        if (nil == persistedBuddy) {
            
            println("persisting user \(buddy.name) \(buddy.serverID)")
            persistedBuddy = Buddy.MR_createEntity() as? Buddy
            
            persistedBuddy!.name = buddy.name
            persistedBuddy!.serverID = buddy.serverID
            
            NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
        }
    }
}