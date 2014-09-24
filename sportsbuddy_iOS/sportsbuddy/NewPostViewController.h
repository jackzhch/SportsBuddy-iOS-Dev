//
//  NewPostViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/27/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPostViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *postTitle;
@property (strong, nonatomic) IBOutlet UITextView *postContent;

@end
