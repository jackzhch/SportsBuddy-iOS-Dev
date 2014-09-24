//
//  TeamViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/24/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "TeamViewController.h"
#import "TeamTableViewCell.h"
#import "TeamDetailViewController.h"
#import <Parse/Parse.h>

@interface TeamViewController ()

@end

@implementation TeamViewController {
    
    NSString *selectedTeamID;
    UIImage *selectedTeamImage;
    NSMutableArray *teamIDs;
    NSMutableArray *teamImages;  // cached team images
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
    // set delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

// before tableview appears, retrieve most up-to-date content
- (void)viewWillAppear:(BOOL)animated {
    
    // retrieve my teams from back-end
    self.myTeams = [[NSMutableArray alloc] init];
    teamImages = [[NSMutableArray alloc] init]; 
    teamIDs = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Team"];
        
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@, %@", error ,[error userInfo]);
        } else {
            // display only teams that current user is a member of
            NSString *currentUserID = [[PFUser currentUser] objectId];
            for (PFObject *team in objects) {
                NSArray *memberIDs = team[@"members"];
                if ([memberIDs containsObject:currentUserID]) {
                    [self.myTeams addObject:team];
                    [teamIDs addObject:[team objectId]];
                }
            }
            // add placeholder object
            for (int i = 0; i < [self.myTeams count]; i++) {
                [teamImages addObject:[NSNull null]];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myTeams count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //    cell.backgroundColor = [UIColor colorWithRed:205.0 / 255 green:0.0/255 blue:0.0/255 alpha:1];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"TeamTableCell";
    TeamTableViewCell *tablecell = (TeamTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
    PFObject *team = [self.myTeams objectAtIndex:indexPath.row];
    UIImage *image = [teamImages objectAtIndex:indexPath.row];

    // team name
    tablecell.teamName.text = team[@"name"];
    [tablecell.teamName setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];

    if (![image isEqual:[NSNull null]]) {
        tablecell.teamImage.image = image;
    } else {
        // team emblem
        PFFile *teamImageFile = team[@"emblem"];
        NSURL *imageUrl = [[NSURL alloc] initWithString:teamImageFile.url];
        
        // download the image asynchronously
        [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                tablecell.teamImage.image = image;
                // cache the image for use later (when scrolling up)
                teamImages[indexPath.row] = image;
            }
        }];
    }
    
    // sports type
    tablecell.sportsType.text = team[@"sportsType"];
    [tablecell.sportsType setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    
    return tablecell;
    
}

// pass information between controllers
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTeamDetail"]) {
        TeamDetailViewController *destinationVC = (TeamDetailViewController *) segue.destinationViewController;
        destinationVC.teamID = selectedTeamID;
        destinationVC.teamImage = selectedTeamImage;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedTeamID = teamIDs[indexPath.row];
    selectedTeamImage = teamImages[indexPath.row];
    [self performSegueWithIdentifier:@"showTeamDetail" sender:self];
}

#pragma mark - Helper methods
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

@end
