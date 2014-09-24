//
//  NewTeamViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/28/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface NewTeamViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *teamTitle;
@property (strong, nonatomic) IBOutlet UITextView *teamDescription;
@property (strong, nonatomic) IBOutlet UITextField *sportsType;
@property (strong, nonatomic) IBOutlet UIImageView *teamEmblem;
@property BOOL newMedia;


@end
