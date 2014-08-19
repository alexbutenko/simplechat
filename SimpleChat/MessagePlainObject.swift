//
//  MessagePlainObject.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/16/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class MessagePlainObject {
    var value:String
    var serverID:String
    var ownerID:String
    var date:NSDate
    
    init(value:String, serverID:String, ownerID:String, date:NSDate) {
        self.value = value;
        self.serverID = serverID
        self.ownerID = ownerID
        self.date = date
    }
    
    func description() -> String {
        return value + " ID: " + serverID + " date: " + date.description
    }
}