//
//  AddEventViewController.h
//  sportsbuddy
//
//  Created by DoodleJack on 7/29/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventItem.h"

@interface AddEventViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *eventType;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *eventNotes;
@property (weak, nonatomic) IBOutlet UILabel *maxPeople;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDate;
@property (strong, nonatomic) IBOutlet UIButton *setLocationButton;
@property (weak, nonatomic) IBOutlet UITextField *eventVisibility;

@property (strong, nonatomic) IBOutlet UILabel *sportsTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *maxPeopleLabel;
@property (strong, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property EventItem *eventItem;
@property (strong, nonatomic) NSNumber *eventLatitude;
@property (strong, nonatomic) NSNumber *eventLongitude;

- (void)updateLocation: (NSString *)address withLatitude:(NSNumber *)latitude andLongitude:(NSNumber *)longitude;

@end
