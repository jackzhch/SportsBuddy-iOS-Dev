//
//  TeamSearchViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/29/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl1;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl2;
@property (strong, nonatomic) IBOutlet UISearchBar *teamSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *allTeams;
@property (strong, nonatomic) NSMutableArray *filteredTeams;


@end
