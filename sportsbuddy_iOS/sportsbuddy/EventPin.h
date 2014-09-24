//
//  EventPin.h
//  sportsbuddy
//
//  Created by DoodleJack on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface EventPin : NSObject<MKAnnotation, NSCopying>
    @property (strong, nonatomic) NSString *title;
    @property (strong, nonatomic) NSString *subtitle;
    @property (nonatomic,assign) CLLocationCoordinate2D coordinate;
    
-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subTitle:(NSString *) subtitle;
    @end