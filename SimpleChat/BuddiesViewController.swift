//
//  ViewController.swift
//  SimpleChat
//
//  Created by alexbutenko on 6/10/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import UIKit

class BuddiesViewController: JSMessagesViewController {
    
    lazy var viewModel:BuddiesViewModel = BuddiesViewModel()
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        viewModel.onDidLoadData = {isInitial in
            if (isInitial) {
                self.activityIndicator!.stopAnimating()
                self.tableView.reloadData()
            }
            
            self.scrollToBottomAnimated(false)
        }
        
        viewModel.onDidSendMessage = {
            self.finishSend()
            self.scrollToBottomAnimated(true)
        }
        
        self.delegate = viewModel
        self.dataSource = viewModel
        
        super.viewDidLoad()
        
        viewModel.tableView = tableView
        
        view.bringSubviewToFront(activityIndicator!)
        
        JSBubbleView.appearance().font = UIFont.systemFontOfSize(16.0)
    
        title = "Messages";
        messageInputView.textView.placeHolder = "New Message";
        
        setBackgroundColor(UIColor.whiteColor())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Don't show anything if the document hasn't been loaded.
        // We show the items in a list, plus a separate row that lets users enter a new item.
        return viewModel.messages.count
    }
}

