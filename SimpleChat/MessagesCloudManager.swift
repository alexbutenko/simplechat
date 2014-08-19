//
//  MessagesCloudManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/16/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation
import CloudKit

class MessagesCloudManager {
    class func fetchMessagesWithCompletionHandler(completionHandler:([MessagePlainObject]!, NSError!) -> Void) {
        CloudManager.sharedInstance.queryMessages(nil) {
            self.mapMessagesIntoPlainObjectsIfNeeded($0, error: $1, completionHandler)
        }
    }
    
    class func addMessage(text: String, completionHandler: (MessagePlainObject!, NSError!) -> Void) {
        CloudManager.sharedInstance.addMessage(text, buddyRecordName: SenderBuddyDataManager.sharedInstance.persistedBuddy!.serverID) {
            
            if (!$1) {
                println("added message \($0.objectForKey(CloudManager.ModelKeys.MessageValue))")
                
                let ownerReference:CKReference = $0.objectForKey(CloudManager.ModelKeys.MessageOwner) as CKReference

                let messagePlainObject = MessagePlainObject(value: $0.objectForKey(CloudManager.ModelKeys.MessageValue) as String,
                                                         serverID: $0.recordID.recordName,
                                                          ownerID: ownerReference.recordID.recordName,
                                                             date: $0.creationDate)
                
                completionHandler(messagePlainObject, nil)
            } else {
                completionHandler(nil, $1)
            }
        }
    }
    
    class func fetchUpdatedMessages(containmentValidationHandler: (serverID:String) -> Bool, completionHandler: ([MessagePlainObject]!, NSError!) -> Void) {
        CloudManager.sharedInstance.queryUpdatedRecordIDs{recordIDs, error in
            
            if (!error) {
                var filteredIDs = recordIDs.filter {return containmentValidationHandler(serverID: $0.recordName)}
                
                println("recordIDs to fetch data \(filteredIDs)")
                
                CloudManager.sharedInstance.queryMessagesWithIDs(filteredIDs) {
                    self.mapMessagesIntoPlainObjectsIfNeeded($0, error: $1, completionHandler)
                }
            }
        }
    }
    
    class func mapMessagesIntoPlainObjectsIfNeeded(records:[CKRecord]!, error:NSError!, completionHandler:([MessagePlainObject]!, NSError!) -> Void) {
        if (!error) {
            let plainRecords:[MessagePlainObject] = records.map {
                
                let ownerReference:CKReference = $0.objectForKey(CloudManager.ModelKeys.MessageOwner) as CKReference
                
                return MessagePlainObject(value: $0.objectForKey(CloudManager.ModelKeys.MessageValue) as String,
                    serverID: $0.recordID.recordName,
                    ownerID: ownerReference.recordID.recordName,
                    date: $0.creationDate)
            }
            
            completionHandler(plainRecords, nil)
        } else {
            completionHandler(nil, error)
        }
    }
}