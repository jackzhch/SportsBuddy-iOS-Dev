//
//  AddReplyViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/26/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "AddReplyViewController.h"
#import <Parse/Parse.h>

@interface AddReplyViewController ()

@end

@implementation AddReplyViewController

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
    self.replyMessage.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.replyMessage.text = @"";
    self.replyMessage.textColor = [UIColor blackColor];
    [self.replyMessage setReturnKeyType:UIReturnKeyDone];
    return YES;
}


- (void) textViewDidChange:(UITextView *)textView
{
    if (self.replyMessage.text.length == 0) {
        self.replyMessage.textColor = [UIColor lightGrayColor];
        self.replyMessage.text = @"Add your reply here";;
        [self.replyMessage resignFirstResponder];
    }
    
}

// cancel button pressed, dismiss the modal view
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// done button pressed, retrieve the user content and dismiss the modal view
- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    
    NSString *content = self.replyMessage.text;
    if ([content length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Sorry" message:@"Your reply message is empty, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        PFObject *newReply = [PFObject objectWithClassName:@"DiscussionReply"];
        newReply[@"postID"] = self.postID;
        NSLog(@"%@", self.postID);
        newReply[@"userName"] = [[PFUser currentUser] username];
        newReply[@"replyMessage"] = self.replyMessage.text;
        newReply[@"userID"] = [[PFUser currentUser] objectId];
        [newReply saveInBackground];
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
