//
//  NewTeamViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/28/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "NewTeamViewController.h"
#import <Parse/Parse.h>

@interface NewTeamViewController ()

@end

@implementation NewTeamViewController

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
    self.teamDescription.text = @"Give a short description of your team";
    self.teamDescription.textColor = [UIColor lightGrayColor];
    self.teamDescription.delegate = self;
    self.sportsType.delegate = self;
    self.teamTitle.delegate = self;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.teamDescription.text = @"";
    self.teamDescription.textColor = [UIColor blackColor];
    [self.teamDescription setReturnKeyType:UIReturnKeyDone];
    return YES;
}


- (void) textViewDidChange:(UITextView *)textView
{
    if (self.teamDescription.text.length == 0) {
        self.teamDescription.textColor = [UIColor lightGrayColor];
        self.teamDescription.text = @"Give a short description of your team";;
        [self.teamDescription resignFirstResponder];
    }
    
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    self.teamTitle.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.sportsType.autocapitalizationType = UITextAutocapitalizationTypeWords;
}

// create a new team and dismiss the modal view
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    
    PFObject *newTeam = [PFObject objectWithClassName:@"Team"];
    PFUser *teamLeader = [PFUser currentUser];
    if ([self.teamTitle.text length] == 0 ||
        [self.sportsType.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please provide at least valid team name and sports type " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        newTeam[@"leaderID"] = [teamLeader objectId];
        newTeam[@"name"] = self.teamTitle.text;
        newTeam[@"sportsType"] = self.sportsType.text;
        newTeam[@"description"] = self.teamDescription.text;
        NSData *imageData = UIImagePNGRepresentation(self.teamEmblem.image);
        PFFile *imageFile = [PFFile fileWithName:@"emblem.png" data:imageData];
        newTeam[@"emblem"] = imageFile;
        // add user himself as a team member
        NSArray *members = [NSArray arrayWithObject:[teamLeader objectId]];
        newTeam[@"members"] = members;
        
        [newTeam saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSString *newTeamID = [newTeam objectId];
                // add to current user's teams joined
                NSMutableArray *teamsJoined = teamLeader[@"teamsJoined"];
                if (teamsJoined == nil) {
                    NSArray *teams = [NSArray arrayWithObject:newTeamID];
                    teamLeader[@"teamsJoined"] = teams;
                    [teamLeader saveInBackground];
                } else {
                    [teamsJoined addObject:newTeamID];
                    teamLeader[@"teamsJoined"] = teamsJoined;
                    [teamLeader saveInBackground];
                }
            }
        }];
        
        // dismiss the modal view
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    
}

// dismiss the modal view
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// access iOS photo library and set the imageview
- (IBAction)uploadButtonPressed:(UIButton *)sender {
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

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
                        didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        self.teamEmblem.image = image;
        self.teamEmblem.image = [self resizeImage:image toWidth:200 andHeight:200];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Method
- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.teamEmblem.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
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
