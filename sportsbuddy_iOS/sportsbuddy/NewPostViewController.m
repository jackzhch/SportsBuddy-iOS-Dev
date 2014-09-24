//
//  NewPostViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/27/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "NewPostViewController.h"
#import <Parse/Parse.h>

@interface NewPostViewController ()

@end

@implementation NewPostViewController

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
    self.postContent.text = @"What would you like to discuss today?";
    self.postContent.textColor = [UIColor lightGrayColor];
    self.postContent.delegate = self;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.postContent.text = @"";
    self.postContent.textColor = [UIColor blackColor];
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (self.postContent.text.length == 0) {
        self.postContent.textColor = [UIColor lightGrayColor];
        self.postContent.text = @"What would you like to discuss today?";
        [self.postContent resignFirstResponder];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonPressed:(UIBarButtonItem *)sender {
    
    // creates a new DiscussionPost object and save it to the back-end
    PFObject *newPost = [PFObject objectWithClassName:@"DiscussionPost"];
    PFUser *author = [PFUser currentUser];
    if ([self.postTitle.text length] == 0 || [self.postContent.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"It seems like you did not enter valid title/content" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        newPost[@"author"] = author.username;
        newPost[@"authorID"] = [author objectId];
        newPost[@"title"] = self.postTitle.text;
        newPost[@"content"] = self.postContent.text;
        [newPost saveInBackground];
        
        // dismiss the modal view
        [self dismissViewControllerAnimated:YES completion:nil];
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
