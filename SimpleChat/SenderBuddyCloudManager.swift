//
//  UserCloudManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class SenderBuddyCloudManager {
    class func setup(#completion:(BuddyPlainObject!, NSError!)->Void) {
        CloudManager.sharedInstance.requestDiscoverabilityPermission({discoverable, error in
            println("Discoverable: \(discoverable)")
            
            if discoverable {
                
                //TODO: could be better to validate if there are persisted values
                CloudManager.sharedInstance.discoverUserInfo(){userInfo, error in
                    
                    if userInfo != nil {
//                        NSLog("firstname %@ lastname %@ ID %@", userInfo.firstName, userInfo.lastName, userInfo.userRecordID.recordName)
                        
                        CloudManager.sharedInstance.fetchUserWithID(userInfo.userRecordID.recordName) {buddy in
//                            println("buddy \(buddy) userInfo \(userInfo)")
                            if buddy == nil {
                                println("need to create \(userInfo.firstName)")

                                CloudManager.sharedInstance.addBuddy(userInfo.firstName, ID:userInfo.userRecordID.recordName) {record, error in
                                    
                                    if error == nil {
                                        println("created \(userInfo.firstName)")
                                        completion(BuddyPlainObject(name:userInfo.firstName, serverID:userInfo.userRecordID.recordName), error)
                                    }
                                }
                            } else {
                                completion(BuddyPlainObject(name:userInfo.firstName, serverID:userInfo.userRecordID.recordName), error)
                            }
                        }
                    } else {
                        println("No user info")
                        completion(nil, error)
                    }
                }
            } else if error != nil {
                completion(nil, error)
            }
        })
    }
}