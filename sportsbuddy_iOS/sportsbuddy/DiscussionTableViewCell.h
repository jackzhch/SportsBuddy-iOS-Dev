//
//  DiscussionTableViewCell.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/26/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscussionTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *cellImage;
@property (strong, nonatomic) IBOutlet UITextView *cellTitle;
@property (strong, nonatomic) IBOutlet UILabel *cellDate;
@property (strong, nonatomic) IBOutlet UILabel *cellUsername;
@property (strong, nonatomic) IBOutlet UITextView *cellContent;

@end
