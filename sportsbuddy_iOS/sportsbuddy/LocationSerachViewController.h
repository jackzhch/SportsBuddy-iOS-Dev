//
//  LocationSerachViewController.h
//  sportsbuddy
//
//  Created by DoodleJack on 8/1/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventItem.h"
@interface LocationSerachViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property EventItem *eventItem;
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSNumber *positionLatitude;
@property (nonatomic, strong) NSNumber *positionLongitude;

@end
