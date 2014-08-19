//
//  BuddyPlainObject.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class BuddyPlainObject {
    var name:String
    var serverID:String
    
    init(name:String, serverID:String) {
        self.name = name
        self.serverID = serverID
    }
    
    func description() -> String {
        return name + " ID: " + serverID
    }
}