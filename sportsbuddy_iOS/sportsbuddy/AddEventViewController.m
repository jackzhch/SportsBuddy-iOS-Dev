//
//  AddEventViewController.m
//  sportsbuddy
//
//  Created by DoodleJack on 7/29/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <Parse/Parse.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "AddEventViewController.h"
#import "LocationSerachViewController.h"


@interface AddEventViewController () <UITextFieldDelegate>


@end

@implementation AddEventViewController {
    UITextField *activeTextField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // draw dividing lines
    [self addDividingLines];
    
    // add tap gesture recognizer to dimiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // setup delegate
    self.eventType.delegate = self;
    self.eventVisibility.delegate = self;
    self.eventNotes.delegate = self;
    
    // get current system time
    NSDate *minDate = [NSDate new];
    [_eventDate setDatePickerMode:UIDatePickerModeDateAndTime];
    [_eventDate setMinimumDate:minDate];
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
    
}

- (void)keyboardWillShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (activeTextField == self.eventVisibility || activeTextField == self.eventNotes) {
        // keyboard will block textfields, bring the scroll view up
        CGPoint buttonOrigin = activeTextField.frame.origin;
        CGFloat buttonHeight = activeTextField.frame.size.height;
        CGRect visibleRect = self.view.frame;
        visibleRect.size.height -= keyboardSize.height;
        if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
            CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight + 10);
            [self.scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)dismissKeyboard
{
    [activeTextField resignFirstResponder];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setLocationButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showLocationChooser" sender:self];
}

- (IBAction)valueChanged:(UIStepper *)sender {
    
    double value = [sender value];
    [self.maxPeople setText:[NSString stringWithFormat:@"%d", (int)value]];
    
}

- (void)updateLocation: (NSString *)address withLatitude:(NSNumber *)latitude andLongitude:(NSNumber *)longitude {
    [self.setLocationButton setTitle:address forState:UIControlStateNormal];
    self.eventLatitude = latitude;
    self.eventLongitude = longitude;
}

// check for invalid input, create event in back-end, ask user to share on twitter
- (IBAction)createButtonPressed:(UIBarButtonItem *)sender {
    
    //check for invalid input
    if ([self.eventType.text length] == 0 ||
        [self.setLocationButton.titleLabel.text isEqualToString:@"Set Location"] ||
        [self.setLocationButton.titleLabel.text length] == 0 ||
        [self.eventVisibility.text length] == 0 ||
        [self.maxPeople.text isEqualToString:@"0"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Please provide valid information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        // create event on back-end
        PFObject *event = [PFObject objectWithClassName:@"Event"];
        
        event[@"sportType"] = self.eventType.text;
        event[@"visibility"] = self.eventVisibility.text;
        event[@"maxPeople"] = [NSNumber numberWithInteger:[self.maxPeople.text integerValue]];
        event[@"addressText"] = [self.setLocationButton.titleLabel.text stringByAppendingString:@", Pittsburgh"];
        event[@"currentPeople"] = [NSNumber numberWithInteger:1];
        event[@"participants"] = [[NSArray alloc] initWithObjects:[[PFUser currentUser] objectId], nil];
        event[@"latitude"] = self.eventLatitude;
        event[@"longitude"] = self.eventLongitude;
        
        // event date from datepicker
        NSDate *date = self.eventDate.date;
        NSTimeInterval interval = [date timeIntervalSince1970] * 1000; //convert to milliseconds
        
        // get hour and minute
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        NSLog(@"hour: %ld", (long)hour);
        NSLog(@"minute: %ld", (long)minute);
        event[@"hour"] = [NSNumber numberWithInteger:hour];
        event[@"minute"] = [NSNumber numberWithInteger:minute];
        
        // get dateMilliseconds
        double intervalWithoutHourAndDate = interval - hour * 3600 * 1000 - minute * 60 * 1000;
        NSLog(@"dateMilliseconds: %f", intervalWithoutHourAndDate);
        event[@"dateMilliseconds"] = [NSNumber numberWithDouble:intervalWithoutHourAndDate];
        
        // save
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Error occurred, possibly network error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have succesfully created a new event. Would you like to share it on Twitter?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Yes", nil];
                [alertView show];
                
                // add this event to current user's events joined list
                PFUser *user = [PFUser currentUser];
                [user[@"eventsJoined"] addObject:[event objectId]];
                [user saveInBackground];
            }
        }];
    }
}

// create default twitter message
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // check whether user already setup an account on device
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *tweetBox = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetBox setInitialText:[self createDefaultTweet]];
            [self presentViewController:tweetBox animated:YES completion:nil];
        }
        else {
            // alert user to setup account
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"No Twitter account found on device.\
                                      Go to \"Settings\" to setup."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (NSString *)createDefaultTweet {
    
    NSString *tweet = @"Join me to play ";
    tweet = [tweet stringByAppendingString:self.eventType.text];
    tweet = [tweet stringByAppendingString:@" in "];
    tweet = [tweet stringByAppendingString:self.setLocationButton.titleLabel.text];
    tweet = [tweet stringByAppendingString:@" at "];
    NSDate *date = self.eventDate.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm, MMM dd"];
    tweet = [tweet stringByAppendingString:[formatter stringFromDate:date]];
    return tweet;
}


// dismiss keyboard
- (IBAction)backgroundTap:(id)sender {
    [sender resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] != self.eventType && [touch view] != self.eventNotes
        && [touch view] != self.eventVisibility) {
        [self.eventNotes resignFirstResponder];
        [self.eventType resignFirstResponder];
        [self.eventVisibility resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Helper methods
-(void)addDividingLines {
    // add dividing lines between different fields
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(12, self.sportsTypeLabel.frame.origin.y + self.sportsTypeLabel.frame.size.height + 9, self.view.bounds.size.width - 20, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(12, self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 7, self.view.bounds.size.width - 20, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:lineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(12, self.eventDate.frame.origin.y + self.eventDate.frame.size.height + 40, self.view.bounds.size.width - 20, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:lineView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showLocationChooser"]){
        
        LocationSerachViewController *vc = (LocationSerachViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        [vc setDelegate:self];
        
    }
}


@end
