//
//  TeamDetailViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/27/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "RequestTableViewController.h"
#import "EventItem.h"
#import <Parse/Parse.h>

@interface TeamDetailViewController ()

@end

@implementation TeamDetailViewController {
    NSMutableArray *memberImages;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Get data from parse
    PFObject *team = [PFQuery getObjectOfClass:@"Team" objectId:self.teamID];
    
    // name
    self.teamName = team[@"name"];
    
    // leaderID
    self.leaderID = team[@"leaderID"];
    
    // teamMembers
    self.teamMembers = [NSMutableArray arrayWithArray:team[@"members"]];
    
    // set default member image when downloading
    memberImages = [[NSMutableArray alloc] init];

    for (int i = 0; i < [self.teamMembers count]; i++) {
        NSString *memberID = self.teamMembers[i];
        PFFile *imageFile = [PFQuery getUserObjectWithId:memberID][@"avatar"];
        NSURL *imageUrl = [NSURL URLWithString:imageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        [memberImages addObject:[UIImage imageWithData:imageData]];
    }
    
    // team image    
    self.teamImageView.image = self.teamImage;
    self.teamNameLabel.text = self.teamName;
    
    // retrieve the next upcoming event
    PFQuery *query = [PFQuery queryWithClassName:@"team"];
    [query whereKey:@"visibility" equalTo:self.teamName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects != nil && [objects count] > 0) {
                
                EventItem *nearestEvent;
                
                for (PFObject *event in objects) {
                    
                    // create new EventItem object and add to upcomingEvent list
                    EventItem *newEvent = [[EventItem alloc] init];
                    newEvent.eventType = event[@"sportType"];
                    NSTimeInterval timeInterval = [event[@"dateMilliseconds"] doubleValue] / 1000;
                    timeInterval += [event[@"hour"] doubleValue] * 60 * 60;
                    timeInterval += [event[@"minute"] doubleValue] * 60;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                    newEvent.eventTime = date;
                    newEvent.eventLoc = event[@"addressText"];
                    
                    NSDate *today = [NSDate date];
                    
                    // see if its the nearest upcoming event
                    if (nearestEvent == nil) {
                        nearestEvent = newEvent;
                    } else {
                        // see if the event is in the future
                        if ([newEvent.eventTime earlierDate:today] == today) {
                            // see if its the closest
                            if ([newEvent.eventTime earlierDate:nearestEvent.eventTime] == newEvent.eventTime) {
                                nearestEvent = newEvent;
                            }
                        }
                    }
                }
                
                self.nextEventLabelTime.text = @"Next Event: ";
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MMM,dd"];
                NSString *dateString = [formatter stringFromDate:nearestEvent.eventTime];
                self.nextEventLabelLocation.text = [self.nextEventLabelLocation.text stringByAppendingString:dateString];
                self.nextEventLabelLocation.text = nearestEvent.eventLoc;
            }
        }
    }];
    
    // add "Manage Requests" button programmatically when current user is the leader
    if ([[[PFUser currentUser] objectId] isEqualToString:self.leaderID]) {
        UIBarButtonItem *manageRequestButton = [[UIBarButtonItem alloc]
                                                initWithTitle:@"Manage Requests"
                                                style:UIBarButtonItemStyleBordered
                                                target:self
                                                action:@selector(showRequestsModalView)];
        self.navigationItem.rightBarButtonItem = manageRequestButton;
    }
    
    // Configure scrollview
    self.scrollView.delegate = self;
    [self.scrollView setCanCancelContentTouches:NO];
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = NO;
    
    // populate data in scrollview
    [self updateScrollView];
}

// update the display in scrollview
- (void)updateScrollView {
    
    //clears the scrollview
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    // redraw the scrollview
    CGFloat imageGap = 20;
    CGFloat labelGap = 30;
    NSMutableArray *memberNames = [[NSMutableArray alloc] init];
    for (NSString *memberID in self.teamMembers) {
        // get user image and name label
        PFUser *member = [PFQuery getUserObjectWithId:memberID];
        [memberNames addObject:[member username]];
        // look for team leader
        if ([memberID isEqualToString:self.leaderID]) {
            self.leaderName = [member username];
        }
    }
    
    for (int i = 0; i < [self.teamMembers count]; i++) {
        
        // add member image
        UIImage *memberImage = [memberImages objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:memberImage];
        CGRect imageRect = imageView.frame;
        imageRect.size.height = 80;
        imageRect.size.width = 80;
        imageRect.origin.x = imageGap;
        imageRect.origin.y = 0;
        imageView.frame = imageRect;
        [self.scrollView addSubview:imageView];
    
        // add member name label
        CGRect nameLabelRect = CGRectMake(labelGap, imageRect.size.height, imageRect.size.width + 30, 30);
        UILabel *memberName = [[UILabel alloc] initWithFrame:nameLabelRect];
        memberName.text = memberNames[i];
        if ([memberName.text isEqualToString:self.leaderName]) {
            memberName.text = [memberName.text stringByAppendingString:@"(c)"];
        }
        [self.scrollView addSubview:memberName];
        
        imageGap += imageView.frame.size.width + 40;
        labelGap += imageView.frame.size.width + 42.5;
    }
    
    self.scrollView.contentSize = CGSizeMake(imageGap, [self.scrollView bounds].size.height);
}

// pop up an UIAlertView to ask user to confirm leaving the team
- (IBAction)buttonLeaveTeamPressed:(UIButton *)sender {
    // alert user
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm exit" message:@"Are you sure you want to leave the team?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

// after user confirms his wish to leave the team, remove him from the team
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        PFUser *user = [PFUser currentUser];
        NSString* userID = [user objectId];
        
        // remove from local data structure
        [self.teamMembers removeObject:userID];
        
        // update scrollview
        [self updateScrollView];
        
        // update back-end
        PFObject *targetTeam = [PFQuery getObjectOfClass:@"Team" objectId:self.teamID];
        [targetTeam[@"members"] removeObject:userID];
        [targetTeam saveInBackground];
        
        // remove teamID from current user's teamsJoined list
        [user[@"teamsJoined"] removeObject:self.teamID];
        [user saveInBackground];
        
        // pop to root view
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

// switch in a modal view that lets the team leader manages join request
- (void)showRequestsModalView {
    [self performSegueWithIdentifier:@"showRequests" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // pass teamID to manage request modal view
    if ([segue.identifier isEqualToString:@"showRequests"]) {
        RequestTableViewController *destinationVC = (RequestTableViewController *) [[[segue destinationViewController] viewControllers] objectAtIndex:0];
        destinationVC.teamID = self.teamID;
    }

}

@end
