//
//  EventMapViewController.h
//  sportsbuddy
//
//  Created by DoodleJack on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventItem.h"

@interface EventMapViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property EventItem *selectedEvent;
@property (strong,nonatomic) NSMutableArray *eventItems;
@property (strong,nonatomic) NSMutableDictionary *eventPinMapping;
@property (strong,nonatomic) NSMutableDictionary *pinButtonMapping;

- (IBAction)unwindToMap:(UIStoryboardSegue *)segue;

@end
