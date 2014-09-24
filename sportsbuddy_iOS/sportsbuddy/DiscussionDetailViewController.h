//
//  DiscussionDetailViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/26/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ReplyTableViewCell.h"

@interface DiscussionDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *authorImage;
@property (strong, nonatomic) IBOutlet UILabel *authorName;
@property (strong, nonatomic) IBOutlet UITextView *postTitle;
@property (strong, nonatomic) IBOutlet UITextView *postContent;
@property (strong, nonatomic) PFObject *post;
@property (strong, nonatomic) NSMutableArray *replyMsgs;
@property (strong, nonatomic) UIImage *userImage;

@end
