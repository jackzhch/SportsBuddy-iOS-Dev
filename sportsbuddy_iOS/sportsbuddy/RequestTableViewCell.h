//
//  RequestTableViewCell.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *approveButton;
@property (strong, nonatomic) IBOutlet UIButton *ignoreButton;

@end
