//
//  DiscussionViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/24/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscussionTableViewCell.h"

@interface DiscussionViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *postsArray;

@end
