//
//  BuddiesDataManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/16/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class BuddiesDataManager {
    
    struct SingleInstance {
        static let sharedUserDataManager: BuddiesDataManager = {
            let userDataManager = BuddiesDataManager()
            
            return userDataManager
            }()
    }
    
    class var sharedInstance: BuddiesDataManager {
        return SingleInstance.sharedUserDataManager
    }
    
    var persistedBuddies:[Buddy]?
    
    func setup(#buddies:[BuddyPlainObject]) {
        
        persistedBuddies = Buddy.MR_findAll() as? [Buddy]
        
        if persistedBuddies != nil {
            
            var processingBuddies = persistedBuddies!.filter{$0.serverID != SenderBuddyDataManager.sharedInstance.persistedBuddy!.serverID}
            
            if processingBuddies.count > 0 {
                var persistedBuddiesIDs:[String] = []
                
                for buddy in persistedBuddies! {
                    persistedBuddiesIDs.append(buddy.serverID)
                }
                
                var buddiesToPersist:[BuddyPlainObject] = []
                
                for buddy in buddies {
                    if !contains(persistedBuddiesIDs, buddy.serverID) {
                        buddiesToPersist.append(buddy)
                    }
                }
                
                for buddyToPersist in buddiesToPersist {
                    println("persisting user \(buddyToPersist.name) \(buddyToPersist.serverID)")
                    var persistedBuddy = Buddy.MR_createEntity() as Buddy
                    
                    persistedBuddy.name = buddyToPersist.name
                    persistedBuddy.serverID = buddyToPersist.serverID
                    
                    processingBuddies.append(persistedBuddy)
                }
                
                processingBuddies.append(SenderBuddyDataManager.sharedInstance.persistedBuddy!)
                
                persistedBuddies = processingBuddies
                
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
            }
        }
    }
}
