//
//  RequestTableViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "RequestTableViewController.h"
#import "RequestTableViewCell.h"
#import "MyButton.h"
#import <Parse/Parse.h>

@interface RequestTableViewController ()

@end

@implementation RequestTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.requests = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// retrieve data from back-end to populate tableview
- (void)viewWillAppear:(BOOL)animated {
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"teamID" equalTo:self.teamID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@, %@", error ,[error userInfo]);
        } else {
            self.requests = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        }
    }];
}

// dismiss modal view when "done" button is pressed
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.requests count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:66.0 / 255 green:66.0/255 blue:66.0/255 alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RequestCell";
    RequestTableViewCell *tablecell = (RequestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFObject *request = [self.requests objectAtIndex:indexPath.row];
    
    // configure request user image
    UIImageView *userImageView = (UIImageView *)[tablecell viewWithTag:100];
    userImageView.image = [UIImage imageNamed:@"User.png"];
    
    // configure request user name
    UILabel *usernameLabel = (UILabel *)[tablecell viewWithTag:101];
    usernameLabel.text = request[@"userName"];
    [usernameLabel setTextColor:[UIColor whiteColor]];
    
    // configure buttons
    [((MyButton *)tablecell.approveButton) setIndexPath:indexPath];
    [((MyButton *)tablecell.ignoreButton) setIndexPath:indexPath];
    [tablecell.approveButton addTarget:self action:@selector(approveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [tablecell.ignoreButton addTarget:self action:@selector(ignoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return tablecell;
}

// add a member to team, delete request from back-end, update tableview
- (void)approveButtonPressed:(MyButton *)sender{
    PFObject *request = [self.requests objectAtIndex:sender.indexPath.row];
    
    // update team member
    NSString *userID = request[@"userID"];
    PFObject *targetTeam = [PFQuery getObjectOfClass:@"Team" objectId:self.teamID];
    [targetTeam[@"members"] addObject:userID];
    [targetTeam saveInBackground];
    
    // to be compatible
    PFObject *approvedRequest = [PFObject objectWithClassName:@"ApprovedRequest"];
    approvedRequest[@"userID"] = userID;
    approvedRequest[@"teamID"] = self.teamID;
    [approvedRequest saveInBackground];
    
    // delete the request entry both locally and from back-end
    [request deleteInBackground];
    [self.requests removeObject:request];
    
    // update tableview
    [self.tableView reloadData];
}

// ignore a member request, delete request from back-end, update tableview
- (void) ignoreButtonPressed:(MyButton *)sender {
    PFObject *request = [self.requests objectAtIndex:sender.indexPath.row];
    
    // delete the request entry
    [request deleteInBackground];
    [self.requests removeObject:request];
    
    // update tableview
    [self.tableView reloadData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
