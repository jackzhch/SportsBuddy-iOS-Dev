//
//  EventPin.m
//  sportsbuddy
//
//  Created by DoodleJack on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "EventPin.h"

@implementation EventPin

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subTitle:(NSString *)subtitle {
    if ((self = [super init])) {
        self.coordinate =coordinate;
        self.title = title;
        self.subtitle = subtitle;
    }
    return self;
}

@end


