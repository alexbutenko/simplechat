//
//  MessagesDataManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/16/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation

class MessagesDataManager {
    
    struct SingleInstance {
        static let sharedUserDataManager: MessagesDataManager = {
            let userDataManager = MessagesDataManager()
            
            return userDataManager
        }()
    }
    
    class var sharedInstance: MessagesDataManager {
        return SingleInstance.sharedUserDataManager
    }
    
    lazy var persistedMessages:[Message]? = Message.MR_findAll() as? [Message]
    
    func setupWithMessages(plainMessages:[MessagePlainObject]) {
        persistedMessages = Message.MR_findAll() as? [Message]

        if persistedMessages != nil {
            
            var processingMessages = persistedMessages!
            
            var persistedMessagesIDs:[String] = [String]()
            
            for message in processingMessages {
                persistedMessagesIDs.append(message.serverID)
            }
            
            var messagesToPersist:[MessagePlainObject] = [MessagePlainObject]()
            
            for plainMessage in plainMessages {
                if (!contains(persistedMessagesIDs, plainMessage.serverID)) {
                    messagesToPersist.append(plainMessage)
                }
            }
            
            for messageToPersist in messagesToPersist {
                processingMessages.append(createMessage(messageToPersist))
            }
            
            persistedMessages = processingMessages
            
            NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
        }
    }
    
    func createMessage(messagePlainObject:MessagePlainObject) -> Message  {
        println("persisting message \(messagePlainObject.value) \(messagePlainObject.serverID) \(messagePlainObject.ownerID)")
        var persistedMessage = Message.MR_createEntity() as Message
        
        persistedMessage.value = messagePlainObject.value
        persistedMessage.serverID = messagePlainObject.serverID
        persistedMessage.date = messagePlainObject.date
        
        
        if let buddiesToFilter = BuddiesDataManager.sharedInstance.persistedBuddies
        {
            let filteredBuddies = buddiesToFilter.filter{$0.serverID == messagePlainObject.ownerID};
            
            if (filteredBuddies.count > 0) {
                persistedMessage.owner = filteredBuddies[0]
                
                println("message owner \(persistedMessage.owner.name) with ID \(messagePlainObject.ownerID)")
            } else {
                persistedMessage.owner = Buddy.MR_createEntity() as Buddy
                
                persistedMessage.owner.name = "Test"
                persistedMessage.owner.serverID = "0"
            }
        }
        return persistedMessage
    }
    
    func addMessage(messagePlainObject:MessagePlainObject) {
        var processingMessages = [Message]()
        
        if persistedMessages != nil {
            processingMessages = persistedMessages!
        }
        
        processingMessages.append(createMessage(messagePlainObject))
        persistedMessages = processingMessages
        
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
    }
}
