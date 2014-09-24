//
//  ProfileViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/24/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "EventItem.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // set user name
    self.userName.text = [[PFUser currentUser] username];
    
    // set user image
    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(117, 45, 80, 80)];
    PFUser *user = [PFUser currentUser];
    PFFile *imageFile = user[@"avatar"];
    if (imageFile) {
        NSURL *imageUrl = [[NSURL alloc] initWithString:imageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        [self.userImageView setImage:[UIImage imageWithData:imageData]];
    } else {
        [self.userImageView setImage:[UIImage imageNamed:@"team_member.png"]];
    }
    [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview: self.userImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    // get upcoming events
    PFUser *user = [PFUser currentUser];
    self.upcomingEvents = [[NSMutableArray alloc] init];
    NSArray *eventIDs = user[@"eventsJoined"];
    for (NSString *eventID in eventIDs) {
        PFObject *event = [PFQuery getObjectOfClass:@"Event" objectId:eventID];
        NSTimeInterval timeInterval = [event[@"dateMilliseconds"] doubleValue] / 1000;
        timeInterval += [event[@"hour"] doubleValue] * 60 * 60;
        timeInterval += [event[@"minute"] doubleValue] * 60;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSDate *today = [NSDate date];
        if ([date earlierDate:today] == today) {
            
            // create new EventItem object and add to upcomingEvent list
            EventItem *newEvent = [[EventItem alloc] init];
            newEvent.eventType = event[@"sportType"];
            newEvent.eventTime = date;
            newEvent.eventLoc = event[@"addressText"];
            [self.upcomingEvents addObject:newEvent];
        }
    }
    
    // sort
    [self.upcomingEvents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[EventItem class]] && [obj2 isKindOfClass:[EventItem class]]) {
            EventItem *event1 = obj1;
            EventItem *event2 = obj2;
            
            if ([event1.eventTime earlierDate:event2.eventTime] == event1.eventTime) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ([event1.eventTime earlierDate:event2.eventTime] == event2.eventTime){
                return (NSComparisonResult)NSOrderedDescending;
            } else
                return (NSComparisonResult)NSOrderedSame;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOut:(UIButton *)sender {
    // Use UIAlertView to ask user to confirm logout
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Logout" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

// log out user
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [PFUser logOut];
        [self performSegueWithIdentifier:@"logOut" sender:self];
    }
}

// ask user either to select a photo from the library or take one with the camera
- (IBAction)updatePhotoButtonPressed:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        self.newMedia = NO;
    }
}

#pragma mark - Helper Method
- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.userImageView.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor darkGrayColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.upcomingEvents count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    EventItem *event = [self.upcomingEvents objectAtIndex:indexPath.row];
    NSString *cellText = @"";
    NSDate *date = event.eventTime;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM, dd"];
    NSString *dateString = [formatter stringFromDate:date];
    cellText = [cellText stringByAppendingString:dateString];
    cellText = [cellText stringByAppendingString:@"--"];
    cellText = [cellText stringByAppendingString:event.eventType];
    cellText = [cellText stringByAppendingString:@"--"];
    NSString *locText = event.eventLoc;
    NSRange range = [locText rangeOfString:@","];
    if (range.location != NSNotFound) {
        locText = [NSString stringWithString:[locText substringToIndex:range.location]];
    }
    cellText = [cellText stringByAppendingString:locText];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    
    cell.textLabel.text = cellText;
    
    return cell;
    
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];

    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        // resize image and save image to back-end
        PFUser *user = [PFUser currentUser];

        // update locally
        self.userImageView.image = image;
        self.userImageView.image = [self resizeImage:image toWidth:200 andHeight:200];
        
        // update on back-end
        UIImage *resizedImage = self.userImageView.image;
        NSData *imageData = UIImagePNGRepresentation(resizedImage);
        PFFile *imageFile = [PFFile fileWithData:imageData];
        user[@"avatar"] = imageFile;
        [user saveInBackground];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
    
}




@end
