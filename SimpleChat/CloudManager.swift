//
//  CloudManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 6/11/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation
import CloudKit

class CloudManager {
    
    struct ModelKeys {
        static let BuddyType = "Buddy"
        static let BuddyName = "BuddyName"
        static let BuddyID = "BuddyID"
        static let MessageType = "BuddyMessage"
        static let MessageValue = "MessageValue"
        static let MessageOwner = "MessageOwner"
    }
    
    struct SubscriptionKeys {
        static let IsSubscribed = "subscribed"
        static let ID = "subscriptionID"
        static let PreviousChangeToken = "PreviousChangeToken"
    }
    
    struct SingleInstance {
        static let sharedCloudManager: CloudManager = {
            let cloudManager = CloudManager()

            //uncomment to remove subscriptions
//            cloudManager.querySubscriptions{IDs, error in
//                if (!error) {
//                    cloudManager.unsubscribe(IDs)
//                }
//            }
            cloudManager.subscribeToNewMessagesIfNeeded()
            
            return cloudManager
            }()
    }
    
    class var sharedInstance: CloudManager {
        return SingleInstance.sharedCloudManager
    }
    
    // MARK: Class Properties
    
    var subscribed:Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(SubscriptionKeys.IsSubscribed)
        }
    }

    var previousChangeToken:CKServerChangeToken?
    {
        get {
            let encodedObjectData = NSUserDefaults.standardUserDefaults().objectForKey(SubscriptionKeys.PreviousChangeToken) as? NSData
            
            if (nil != encodedObjectData) {
                return NSKeyedUnarchiver.unarchiveObjectWithData(encodedObjectData!) as? CKServerChangeToken
            }
            
            return nil
        }
        set(newToken) {
            if (nil != newToken) {
                println("new token \(newToken)")
                
                NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(newToken!), forKey:SubscriptionKeys.PreviousChangeToken)
            }
        }
    }

    var container: CKContainer {
        return CKContainer.defaultContainer()
    }
    
    var publicDatabase: CKDatabase {
        return container.publicCloudDatabase
    }
    
    func requestDiscoverabilityPermission(completionHandler: (Bool, NSError?) -> Void) {
        container.statusForApplicationPermission(.PermissionUserDiscoverability, completionHandler: {status, error in
            
            if (error != nil) {
                NSLog("statusForApplicationPermission error occured %@", error);
            }
            
            if (status == CKApplicationPermissionStatus.InitialState) {
                self.container.requestApplicationPermission(.PermissionUserDiscoverability, {status, error in
                    if (error != nil) {
                        NSLog("requestApplicationPermission error occured %@", error);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {completionHandler(status == CKApplicationPermissionStatus.Granted, error)})
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {completionHandler(true, error)})
            }
        })
    }
    
    func discoverUserInfo(completionHandler: (CKDiscoveredUserInfo!, NSError?) -> Void) {
        
        container.fetchUserRecordIDWithCompletionHandler({(recordId: CKRecordID!, error: NSError!) in
            if (error != nil) {
                NSLog("fetchUserRecordIDWithCompletionHandler error occured %@", error)
                dispatch_async(dispatch_get_main_queue(), {completionHandler(nil, error)})
                
            } else {
                self.container.discoverUserInfoWithUserRecordID(recordId, {userInfo, error in
                    if (error != nil) {
                        NSLog("discoverUserInfoWithUserRecordID error occured %@", error)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {completionHandler(userInfo, error)})
                })
            }
            })
    }
    
    func fetchRecordsOfType(type: String, completionHandler: ([CKRecord], NSError!) -> Void) {
        var records = [CKRecord]()
        
        let predicate = NSPredicate(value: true)
        var query = CKQuery(recordType: type, predicate: predicate)
        
        var queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordFetchedBlock = { record in
            records.append(record)
        }
        
        queryOperation.queryCompletionBlock = {_, error in
            if (error != nil) {
                println(error)
            }
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(records, error)})
        }
        
        publicDatabase.addOperation(queryOperation)
    }
    
    func fetchRecordWithID(recordIDString: String, completionHandler: (CKRecord, NSError!) -> Void) {
        let recordID = CKRecordID(recordName: recordIDString)
        
        publicDatabase.fetchRecordWithID(recordID, {record, error in
            if (error != nil) {
                println(error)
            }
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(record, error)})
            })
    }
    
    func fetchRecordWithID(recordIDString: String, recordType: String, completionHandler: (CKRecord?) -> Void) {
        fetchRecordsOfType(recordType) {records, error in
//            println("records \(records)")
            records.filter({record in
                return record.objectForKey(ModelKeys.BuddyID) as NSString == recordIDString
            })
            
            if (records.count > 0) {
                completionHandler(records[0])
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func addBuddy(name: String, ID: String, completionHandler: (CKRecord!, NSError!) -> Void) {
        var record = CKRecord(recordType: ModelKeys.BuddyType)
        record.setObject(name, forKey: ModelKeys.BuddyName)
        record.setObject(ID, forKey: ModelKeys.BuddyID)

        publicDatabase.saveRecord(record, {record, error in
            if (error != nil) {
                NSLog("saveRecord error %@", error)
            }
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(record, error)})
        })
    }
    
    func fetchBuddies(completionHandler: ([CKRecord]!, NSError!) -> Void) {
        
        fetchRecordsOfType(ModelKeys.BuddyType, completionHandler)
    }
    
    func fetchUserWithID(recordIDString: String, completionHandler: (CKRecord?) -> Void) {
        fetchRecordWithID(recordIDString, recordType: ModelKeys.BuddyType, completionHandler: completionHandler)
    }
    
    func addMessage(message: String, buddyRecordName:String, completionHandler: (CKRecord!, NSError!) -> Void) {
        var record = CKRecord(recordType: ModelKeys.MessageType)
        record.setObject(message, forKey: ModelKeys.MessageValue)
        
        let buddyRecordID = CKRecordID(recordName: buddyRecordName)
        let buddyReference = CKReference(recordID: buddyRecordID, action: .DeleteSelf)
        
        record.setObject(buddyReference, forKey: ModelKeys.MessageOwner)
        
        publicDatabase.saveRecord(record, {record, error in
            if (error != nil) {
                NSLog("saveRecord error %@", error)
            }
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(record, error)})
        })
    }
    
    func queryMessages(buddyReferenceName:NSString?, completionHandler: ([CKRecord]!, NSError!) -> Void) {
        var predicate = NSPredicate(value: true)

        if (nil != buddyReferenceName) {

            let recordID = CKRecordID(recordName: buddyReferenceName)
            let buddyReference = CKReference(recordID: recordID, action: .None)
        
            predicate = NSPredicate(format: "MessageOwner == %@", buddyReference)
        }
        
        var query = CKQuery(recordType: ModelKeys.MessageType, predicate: predicate)
        //TODO: check later, now it fails if there are no records
        //        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        var queryOperation = CKQueryOperation(query: query)
        
        var messages:[CKRecord] = []
        
        queryOperation.recordFetchedBlock = {record in messages.append(record)}
        
        queryOperation.queryCompletionBlock = {_, error in
            if (error != nil) {
                println(error)
            } else {
                messages.sort{$0.creationDate.compare($1.creationDate) == NSComparisonResult.OrderedAscending}
            }
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(messages, error)})
        }
        
        publicDatabase.addOperation(queryOperation)
    }
    
    func queryMessagesWithIDs(IDs:[CKRecordID], completionHandler: ([CKRecord]!, NSError!) -> Void) {
        var fetchRecordsOperation = CKFetchRecordsOperation(recordIDs: IDs)
        
        var messages:[CKRecord] = []
        
        fetchRecordsOperation.perRecordCompletionBlock = {record, recordID, error in
            if (error == nil) {
                messages.append(record)
            } else {
                println("failed to get message with ID \(recordID.recordName)")
            }
        }
        
        fetchRecordsOperation.fetchRecordsCompletionBlock = {_, error in
            if (error != nil) {
                println(error)
            } else {
                messages.sort{$0.creationDate.compare($1.creationDate) == NSComparisonResult.OrderedAscending}
            }
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(messages, error)})
        }
        
        publicDatabase.addOperation(fetchRecordsOperation)
    }
    
    //Subscribing
    
    func queryUpdatedRecordIDs(completionHandler:(recordIDs:[CKRecordID], error:NSError!) -> Void) {
        //request all changes, for case, when some changes are missed
        println("prev change token \(previousChangeToken)")
        
        var notificationChangesOperation = CKFetchNotificationChangesOperation(previousServerChangeToken: previousChangeToken)
        
        var fetchedRecordIDs:[CKRecordID] = [CKRecordID]()
        
        //we just care about inserts, we don't care about of changes of records existing in database, that's why it's enough just to save recordIDs
        notificationChangesOperation.notificationChangedBlock = {notification in
            
            let queryNotif = notification as CKQueryNotification
            //            println("fetched  CKQueryNotification \(queryNotif)")
            
            if (!contains(fetchedRecordIDs, queryNotif.recordID)) {
                fetchedRecordIDs.append(queryNotif.recordID)
            }
        }
        
        notificationChangesOperation.fetchNotificationChangesCompletionBlock = {serverChangeToken, error in
            if (error != nil) {
                println("failed to fetch notification \(error)")
            }
            
            self.previousChangeToken = serverChangeToken
            
            completionHandler(recordIDs: fetchedRecordIDs, error: error)
        }
        
        container.addOperation(notificationChangesOperation)
    }
    
    func subscribeToNewMessagesIfNeeded () {
        if (!subscribed) {
            let truePredicate = NSPredicate(value: true)
            var subscription = CKSubscription(recordType: ModelKeys.MessageType, predicate: truePredicate, options: .FiresOnRecordCreation)
            
            var notification = CKNotificationInfo()
            notification.alertBody = "New message";
            subscription.notificationInfo = notification
            
            publicDatabase.saveSubscription(subscription, {subscription, error in
                if (error != nil) { println("failed to subscribe \(error)") }
                else if (subscription != nil) {
                    println("successfully subscribed to message updates \(subscription.subscriptionID)")
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: SubscriptionKeys.IsSubscribed)
                } else {
                    println("failed to subscribe with unknown error")
                }
            })
        }
    }
    
    func querySubscriptions(completionHandler: ([NSString]!, NSError!) -> Void) {
        let queryOperation = CKFetchSubscriptionsOperation.fetchAllSubscriptionsOperation()
        
        var subscriptions:[CKSubscription] = []
        
        queryOperation.fetchSubscriptionCompletionBlock = {subscriptionsDictionary, error in
            if (error != nil) {
                println("failed to fetch subscriptions \(error) , \(subscriptionsDictionary)")
            } else {
                println("fetched subscriptions \(subscriptionsDictionary)")
            }
            
            //subscriptionsDictionary.keys as [String] doesn't work!
            var arrayOfStrings:[NSString] = [NSString]()
            
            for key in subscriptionsDictionary.keys {
                arrayOfStrings.append(key as NSString)
            }
            
            completionHandler(arrayOfStrings, error)
        }
        
        publicDatabase.addOperation(queryOperation)
    }
    
    func unsubscribe(subscriptionsID: [NSString]) {
        var modifyOperation = CKModifySubscriptionsOperation()
        modifyOperation.subscriptionIDsToDelete = subscriptionsID
        
        modifyOperation.modifySubscriptionsCompletionBlock = {savedSubscription, deletedSubscriptionIDs, error in
            if (error != nil) {
                println("failed to unsubscribe \(error)")
            } else {
                println("unsubscribed from \(subscriptionsID)")
                NSUserDefaults.standardUserDefaults().removeObjectForKey(SubscriptionKeys.ID)
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: SubscriptionKeys.IsSubscribed)
            }
        }
        
        publicDatabase.addOperation(modifyOperation)
    }
}