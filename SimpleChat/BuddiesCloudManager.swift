//
//  BuddiesCloudManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class BuddiesCloudManager {
    class func fetchBuddies(#completion:([BuddyPlainObject]!, NSError!) -> Void) {
        CloudManager.sharedInstance.fetchBuddies{records, error in
            if error == nil {
                let plainRecords:[BuddyPlainObject] = records.map {
                    return BuddyPlainObject(name: $0.objectForKey(CloudManager.ModelKeys.BuddyName) as String,
                                            serverID: $0.objectForKey(CloudManager.ModelKeys.BuddyID) as String)
                }
                
                completion(plainRecords, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}