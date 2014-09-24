//
//  AddReplyViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/26/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddReplyViewController : UIViewController<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *replyMessage;
@property (strong, nonatomic) NSString *postID;

@end
