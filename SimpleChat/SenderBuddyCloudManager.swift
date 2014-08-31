//
//  UserCloudManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class SenderBuddyCloudManager {
    class func setupWithCompletionHandler(completionHandler:(BuddyPlainObject!, NSError!)->Void) {
        CloudManager.sharedInstance.requestDiscoverabilityPermission({discoverable, error in
//            println("discoverable \(discoverable)")
            
            if (discoverable) {
                //TODO: could be better to validate if there are persisted values
                CloudManager.sharedInstance.discoverUserInfo(){userInfo, error in
                    
                    if (userInfo != nil) {
//                        NSLog("firstname %@ lastname %@ ID %@", userInfo.firstName, userInfo.lastName, userInfo.userRecordID.recordName)
                        
                        CloudManager.sharedInstance.fetchUserWithID(userInfo.userRecordID.recordName) {buddy in
//                            println("buddy \(buddy) userInfo \(userInfo)")
                            if (nil == buddy) {
                                println("need to create \(userInfo.firstName)")

                                CloudManager.sharedInstance.addBuddy(userInfo.firstName, ID:userInfo.userRecordID.recordName) {record, error in
                                    
                                    if (nil == error) {
                                        println("created \(userInfo.firstName)")
                                        completionHandler(BuddyPlainObject(name:userInfo.firstName, serverID:userInfo.userRecordID.recordName), error)
                                    }
                                }
                            } else {
                                completionHandler(BuddyPlainObject(name:userInfo.firstName, serverID:userInfo.userRecordID.recordName), error)
                            }
                        }
                    } else {
                        completionHandler(nil, error)
                    }
                }
            } else if (nil != error) {
                completionHandler(nil, error)
            }
        })
    }
}