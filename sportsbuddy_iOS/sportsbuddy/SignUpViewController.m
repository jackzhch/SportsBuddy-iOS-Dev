//
//  SignUpViewController.m
//  sportsbuddy
//
//  Created by Wenting Shi on 7/24/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController () {
    UITextField *activeTextField;
}

@end

@implementation SignUpViewController

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
    [self.textFieldUsername setDelegate:self];
    [self.textFieldEmail setDelegate:self];
    [self.textFieldPassword setDelegate:self];
    [self.textFieldPasswordConfirm setDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard
{
    [activeTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// submits the user sign-up info to back-end
- (IBAction)signUpButtonPressed:(UIButton *)sender {
    NSString *username = self.textFieldUsername.text;
    NSString *email = self.textFieldEmail.text;
    NSString *password = self.textFieldPassword.text;
    NSString *passwordConfirm = self.textFieldPasswordConfirm.text;
    
    // check malformed input data
    BOOL dataOK = YES;
    if ([username length] == 0 || [email length] == 0 || [password length] == 0 || [passwordConfirm length] == 0) {
        dataOK = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter all the required fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else if (![password isEqualToString:passwordConfirm]) {
        dataOK = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Two passwords don't match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else if ([email rangeOfString:@"@"].location == NSNotFound) {
        dataOK = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    // contact parse.com to save
    if (dataOK) {
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        
        // assign default image
        UIImage *defaultImage = [UIImage imageNamed:@"User.png"];
        NSData *imageData = UIImagePNGRepresentation(defaultImage);
        PFFile *imageFile = [PFFile fileWithData:imageData];
        newUser[@"avatar"] = imageFile;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                [self performSegueWithIdentifier:@"loginBySignup" sender:self];
            }
        }];
    }
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
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
