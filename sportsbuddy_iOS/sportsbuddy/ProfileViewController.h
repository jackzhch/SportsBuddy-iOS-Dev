//
//  ProfileViewController.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/24/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ProfileViewController : UIViewController<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) NSMutableArray *upcomingEvents;
@property BOOL newMedia;

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;

@end
