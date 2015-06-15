//
//  BuddiesViewModel.swift
//  SimpleChat
//
//  Created by alexbutenko on 7/16/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation
import UIKit

class BuddiesViewModel: NSObject, JSMessagesViewDataSource, JSMessagesViewDelegate, NSFetchedResultsControllerDelegate {
    
    var messages:[Message] {
        get {
            return fetchedResultsController.fetchedObjects as! [Message]
        }
    }
    var buddies:[Buddy] = [Buddy]()
    var onDidSendMessage:(() -> Void)?
    var onDidLoadData:((isInitial:Bool) -> Void)?
    
    var tableView:UITableView! {
        didSet {
            fetchedResultsController = Message.MR_fetchAllSortedBy("date", ascending: true, withPredicate: nil, groupBy: nil, delegate: self)
        }
    }
    
    var fetchedResultsController:NSFetchedResultsController!
    
    override init() {
        super.init()
        SyncManager.setup { (error) -> Void in
            if error != nil {
                println("SYNC FAILED \(error!)")
            } else {
                println("------\nSYNCED SUCCESSFULLY\n------")
                self.buddies = BuddiesDataManager.sharedInstance.persistedBuddies!
                self.onDidLoadData?(isInitial:true)
            }
        }        
    }
    
    // MARK : JSMessagesViewDataSource
    
    /**
    *  Asks the data soruce for the message object to display for the row at the specified index path. The message text is displayed in the bubble at index path. The message date is displayed *above* the row at the specified index path. The message sender is displayed *below* the row at the specified index path.
    *
    *  @param indexPath An index path locating a row in the table view.
    *
    *  @return An object that conforms to the `JSMessageData` protocol containing the message data. This value must not be `nil`.
    */
    func messageForRowAtIndexPath(indexPath: NSIndexPath!) -> JSMessageData! {
        let message:Message = messages[indexPath.row]
        
        return JSMessage(text: message.value,
                       sender: message.owner.name,
                         date: message.date)
    }
    
    /**
    *  Asks the data source for the imageView to display for the row at the specified index path with the given sender. The imageView must have its `image` property set.
    *
    *  @param indexPath An index path locating a row in the table view.
    *  @param sender    The name of the user who sent the message at indexPath.
    *
    *  @return An image view specifying the avatar for the message at indexPath. This value may be `nil`.
    */
    
    func avatarImageViewForRowAtIndexPath(indexPath: NSIndexPath!, sender: String!) -> UIImageView! {
        //just for test with 2 users
        if (sender == "Alex") {
            return UIImageView(image:UIImage(named:"avatar_1"))
        } else {
            return UIImageView(image:UIImage(named:"avatar_2"))
        }
    }
    
    // MARK: JSMessagesViewDelegate
    
    /**
    *  Tells the delegate that the user has sent a message with the specified text, sender, and date.
    *
    *  @param text   The text that was present in the textView of the messageInputView when the send button was pressed.
    *  @param sender The user who sent the message.
    *  @param date   The date and time at which the message was sent.
    */
    
    func didSendText(text: String!, fromSender sender: String!, onDate date: NSDate!) {
        //TODO : add sound
        
        //        if ((self.messages.count - 1) % 2) {
        //            [JSMessageSoundEffect playMessageSentSound];
        //        }
        //        else {
        //            // for demo purposes only, mimicing received messages
        //            [JSMessageSoundEffect playMessageReceivedSound];
        //            sender = arc4random_uniform(10) % 2 ? kSubtitleCook : kSubtitleWoz;
        //        }
        
        SyncManager.addMessage(text) {error in
            if error == nil {
                println("added message \(text)")
                    self.onDidSendMessage?()
            }
        }
    }
    
    /**
    *  Asks the delegate for the message type for the row at the specified index path.
    *
    *  @param indexPath The index path of the row to be displayed.
    *
    *  @return A constant describing the message type.
    *  @see JSBubbleMessageType.
    */
    
    func messageTypeForRowAtIndexPath(indexPath: NSIndexPath!) -> JSBubbleMessageType {
        //for test reasons: split show incoming and outgoing 1 by 1
        return (0 == indexPath.row % 2) ? .Incoming : .Outgoing
    }
    
    /**
    *  Asks the delegate for the bubble image view for the row at the specified index path with the specified type.
    *
    *  @param type      The type of message for the row located at indexPath.
    *  @param indexPath The index path of the row to be displayed.
    *
    *  @return A `UIImageView` with both `image` and `highlightedImage` properties set.
    *  @see JSBubbleImageViewFactory.
    */

    func bubbleImageViewWithType(type: JSBubbleMessageType, forRowAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        //synced with |messageTypeForRowAtIndexPath| for testing, should be modified together
        if (0 == indexPath.row % 2) {
            return JSBubbleImageViewFactory.bubbleImageViewForType(type, color: UIColor.js_bubbleLightGrayColor())
        }
        
        return JSBubbleImageViewFactory.bubbleImageViewForType(type, color: UIColor.js_bubbleBlueColor())
    }
    
    /**
    *  Asks the delegate for the input view style.
    *
    *  @return A constant describing the input view style.
    *  @see JSMessageInputViewStyle.
    */
    func inputViewStyle() -> JSMessageInputViewStyle  {
        return .Flat
    }

    //MARK: NSFetchResultsController
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {        
        if self.onDidLoadData != nil {
            self.onDidLoadData!(isInitial:false)
        }
        
        tableView.endUpdates()
    }
}