//
//  TeamSearchViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/29/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "TeamSearchViewController.h"
#import <Parse/Parse.h>

@interface TeamSearchViewController ()

@end

@implementation TeamSearchViewController {
    NSIndexPath *selectedIndexPath;
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
    [self.segmentControl1 setSelectedSegmentIndex:-1];
    [self.segmentControl2 setSelectedSegmentIndex:-1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.teamSearchBar.delegate = self;
    [self.teamSearchBar becomeFirstResponder];
    
    // retrieve discussion posts from back-end
    PFQuery *query = [PFQuery queryWithClassName:@"Team"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@, %@", error ,[error userInfo]);
        } else {
            self.allTeams = [[NSMutableArray alloc] initWithArray:objects];
            self.filteredTeams = [[NSMutableArray alloc] initWithArray:self.allTeams];
            [self.tableView reloadData];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                  [UIColor whiteColor],
                                                                                                  NSForegroundColorAttributeName, nil]
                                                                                        forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SegmentedControl
- (IBAction)upperSegmentValueChanged:(UISegmentedControl *)sender {
    self.segmentControl2.selectedSegmentIndex = -1;
    // perform filtering
    self.filteredTeams = [[NSMutableArray alloc] init];
    for (int count = 0; count < [self.allTeams count]; count++) {
        PFObject *object = self.allTeams[count];
        if ([object[@"sportsType"] isEqualToString:[self.segmentControl1 titleForSegmentAtIndex:self.segmentControl1.selectedSegmentIndex]]) {
            [self.filteredTeams addObject:object];
        }
    }
    [self.tableView reloadData];
}

- (IBAction)lowerSegmentValueChanged:(UISegmentedControl *)sender {
    self.segmentControl1.selectedSegmentIndex = -1;
    if (self.segmentControl2.selectedSegmentIndex == 3) {
        self.filteredTeams = self.allTeams;
    } else {
        // perform filtering
        self.filteredTeams = [[NSMutableArray alloc] init];
        for (int count = 0; count < [self.allTeams count]; count++) {
            PFObject *object = self.allTeams[count];
            if ([object[@"sportsType"] isEqualToString:[self.segmentControl2 titleForSegmentAtIndex:self.segmentControl2.selectedSegmentIndex]]) {
                [self.filteredTeams addObject:object];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - SearchBar
- (void) searchBarTextDidBeginEditing: (UISearchBar*) searchBar {
    [searchBar setShowsCancelButton: YES animated: YES];
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;

}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // filter by segment
    self.filteredTeams = [[NSMutableArray alloc] init];
    if (self.segmentControl1.selectedSegmentIndex == -1 &&
        self.segmentControl2.selectedSegmentIndex == -1) {
        self.filteredTeams = self.allTeams;
    } else if (self.segmentControl1.selectedSegmentIndex == -1) {
        // see if its "All" selected
        if (self.segmentControl2.selectedSegmentIndex == 3) {
            self.filteredTeams = self.allTeams;
        } else {
            for (int count = 0; count < [self.allTeams count]; count++) {
                PFObject *object = self.allTeams[count];
                if ([object[@"sportsType"] isEqualToString:[self.segmentControl2 titleForSegmentAtIndex:self.segmentControl2.selectedSegmentIndex]]) {
                    [self.filteredTeams addObject:object];
                }
            }
        }
    } else {
        for (int count = 0; count < [self.allTeams count]; count++) {
            PFObject *object = self.allTeams[count];
            if ([object[@"sportsType"] isEqualToString:[self.segmentControl1 titleForSegmentAtIndex:self.segmentControl1.selectedSegmentIndex]]) {
                [self.filteredTeams addObject:object];
            }
        }
    }
    
    // filter by searchText
    if ([searchText length] > 0) {
        // make a copy
        NSMutableArray *doubleFilteredTeams = [[NSMutableArray alloc] init];
        for (PFObject *object in self.filteredTeams) {
            if ([object[@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch].location == 0) {
                [doubleFilteredTeams addObject:object];
            }
        }
        self.filteredTeams = doubleFilteredTeams;
    }
    
    // reload table view
    [self.tableView reloadData];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredTeams count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"TeamSearchCell";
    UITableViewCell *tablecell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFObject *team = [self.filteredTeams objectAtIndex:indexPath.row];
    
    // team name
    tablecell.textLabel.text = team[@"name"];
    [tablecell.textLabel setFont: [UIFont systemFontOfSize:13.0]];
    [tablecell.textLabel setTextColor:[UIColor whiteColor]];
    
    // sports type
    tablecell.detailTextLabel.text = team[@"sportsType"];
    [tablecell.textLabel setFont: [UIFont systemFontOfSize:13.0]];
    
    return tablecell;
    
}

// pop-up an UIAlertView for user confirmation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Join Request" message:@"Do you want to join this team? Team leader will be notified." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alertView show];
    
}

// update back-end, add a new request
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        
        PFObject *newRequest = [PFObject objectWithClassName:@"Request"];
        NSString *userID = [[PFUser currentUser] objectId];
        NSString *userName = [[PFUser currentUser] username];
        PFObject *team = [self.filteredTeams objectAtIndex:selectedIndexPath.row];
        NSString *teamID = [team objectId];
        
        newRequest[@"userID"] = userID;
        newRequest[@"userName"] = userName;
        newRequest[@"teamID"] = teamID;

        [newRequest saveInBackground];
        
    }
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
