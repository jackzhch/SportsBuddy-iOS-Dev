//
//  TeamDetailViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/27/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamDetailViewController : UIViewController<UIScrollViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *teamImageView;
@property (strong, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *buttonLeaveTeam;


@property (strong, nonatomic) UIImage *teamImage;
@property (strong, nonatomic) NSString *teamName;
@property (strong, nonatomic) NSString *teamID;
@property (strong, nonatomic) NSMutableArray *teamMembers;
@property (strong, nonatomic) NSString *leaderID;
@property (strong, nonatomic) NSString *leaderName;
@property (strong, nonatomic) IBOutlet UILabel *nextEventLabelTime;
@property (strong, nonatomic) IBOutlet UILabel *nextEventLabelLocation;

@end
