//
//  CalloutAnnotation.m
//  sportsbuddy
//
//  Created by DoodleJack on 8/2/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "MyCustomAnnotation.h"

#import "EventPin.h"

@implementation MyCustomAnnotation

@synthesize coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}
@end
