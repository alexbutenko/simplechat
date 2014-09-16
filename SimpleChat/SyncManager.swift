//
//  Configurator.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class SyncManager {
    
    class func setup(#completion:(NSError!) -> Void) {
        SenderBuddyCloudManager.setup { (sender, error) -> Void in
            if sender != nil {
                println("SENDER \n\(sender!.name) \(sender!.serverID)")
            
                //persist user object
                SenderBuddyDataManager.sharedInstance.setup(buddy: sender)
            
            } else {
                println("NO SENDER")
                println("error \(error)")
                
                //persist test user
                SenderBuddyDataManager.sharedInstance.setup(buddy: BuddyPlainObject(name:"test", serverID:"123"))
                
                let alert = UIAlertController(title: "Error", message: "Check that you're logged in iCloud to send messages", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                UIApplication.sharedApplication().keyWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
            
            self.fetchBuddiesAndMessages(completion)
        }
    }
    
    class func fetchBuddiesAndMessages(completion:(NSError!) -> Void) {
        BuddiesCloudManager.fetchBuddies { (buddies, error) -> Void in
            if error == nil {
                println("BUDDIES")
                
                for buddy in buddies {
                    println("\(buddy.description())")
                }
                
                BuddiesDataManager.sharedInstance.setup(buddies: buddies!)
                
            } else {
                println("error \(error)")
            }
            
            self.fetchMessages(completion)
        }
    }
    
    class func fetchMessages(completion:(NSError!) -> Void) {
        //fetch messages
        MessagesCloudManager.fetchMessagesWithCompletionHandler() {
            self.handleMessagesWith($0, error: $1, completion: completion)
        }
    }
    
    class func addMessage(text:String, completion:(NSError!) -> Void) {
        MessagesCloudManager.addMessage(text) {messagePlainObject, error in
            if error == nil {
                MessagesDataManager.sharedInstance.addMessage(messagePlainObject)
            } else {
                println("error \(error)")
            }
            
            completion(error)
        }
    }
    
    class func fetchUpdatedMessages(completion:(NSError!) -> Void) {
        MessagesCloudManager.fetchUpdatedMessages({ recordIDString in
            //check that message is not cached
            var messages:[Message] = MessagesDataManager.sharedInstance.persistedMessages!.filter{recordIDString == $0.serverID}
            
            if messages.count > 0 {
                println("underlying message \(messages[0].value) ID: \(messages[0].serverID)")
            } else {
                println("no stored message for ID \(recordIDString)")
            }
            
            return messages.count == 0
        }) {
            self.handleMessagesWith($0, error: $1, completion)
        }
    }
    
    class func handleMessagesWith(messages:[MessagePlainObject]!, error:NSError!, completion:(NSError!) -> Void) {
        if error == nil {
            println("MESSAGES")
            
            for message in messages {
                println("\(message.description())")
            }
            
            MessagesDataManager.sharedInstance.setupWithMessages(messages!)
        } else {
            println("error \(error)")
        }
        
        completion(error)
    }
}