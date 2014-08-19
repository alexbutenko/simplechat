//
//  Configurator.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/15/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class SyncManager {
    
    class func setupWithCompletion(completionHandler:(NSError!) -> Void) {        
        SenderBuddyCloudManager.setupWithCompletionHandler{sender, error in
            
            if (sender) {
                println("SENDER \n\(sender!.name) \(sender!.serverID)")
            
                //persist user object
                SenderBuddyDataManager.sharedInstance.setupWithBuddy(sender!)
            
            } else {
                println("error \(error)")
                
                //persist test user
                SenderBuddyDataManager.sharedInstance.setupWithBuddy(BuddyPlainObject(name:"test", serverID:"123"))
                
                var alert = UIAlertController(title: "Error", message: "Check that you're logged in iCloud to send messages", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                UIApplication.sharedApplication().keyWindow.rootViewController.presentViewController(alert, animated: true, completion: nil)
            }
            
            self.fetchBuddiesAndMessages(completionHandler)
        }
    }
    
    class func fetchBuddiesAndMessages(completionHandler:(NSError!) -> Void) {
        BuddiesCloudManager.fetchBuddiesWithCompletionHandler{buddies, error in
            
            if (!error) {
                println("BUDDIES")
                
                for buddy in buddies {
                    println("\(buddy.description())")
                }
                
                BuddiesDataManager.sharedInstance.setupWithBuddies(buddies!)
                
            } else {
                println("error \(error)")
            }
            
            self.fetchMessages(completionHandler)
        }
    }
    
    class func fetchMessages(completionHandler:(NSError!) -> Void) {
        //fetch messages
        MessagesCloudManager.fetchMessagesWithCompletionHandler {
            self.handleMessagesWith($0, error: $1, completionHandler: completionHandler)
        }
    }
    
    class func addMessage(text:String, completionHandler:(NSError!) -> Void) {
        MessagesCloudManager.addMessage(text) {messagePlainObject, error in
            if (!error) {
                MessagesDataManager.sharedInstance.addMessage(messagePlainObject)
            } else {
                println("error \(error)")
            }
            
            completionHandler(error)
        }
    }
    
    class func fetchUpdatedMessages(completionHandler:(NSError!) -> Void) {
        MessagesCloudManager.fetchUpdatedMessages({ recordIDString in
            //check that message is not cached
            var messages:[Message] = MessagesDataManager.sharedInstance.persistedMessages!.filter{recordIDString == $0.serverID}
            
            if (messages.count > 0) {
                println("underlying message \(messages[0].value) ID: \(messages[0].serverID)")
            } else {
                println("no stored message for ID \(recordIDString)")
            }
            
            return messages.count == 0
        }) {
            self.handleMessagesWith($0, error: $1, completionHandler)
        }
    }
    
    class func handleMessagesWith(messages:[MessagePlainObject]!, error:NSError!, completionHandler:(NSError!) -> Void) {
        if (!error) {
            println("MESSAGES")
            
            for message in messages {
                println("\(message.description())")
            }
            
            MessagesDataManager.sharedInstance.setupWithMessages(messages!)
        } else {
            println("error \(error)")
        }
        
        completionHandler(error)
    }
}