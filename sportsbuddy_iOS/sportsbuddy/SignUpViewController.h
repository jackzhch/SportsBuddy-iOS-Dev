//
//  SignUpViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/24/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPasswordConfirm;

@end
