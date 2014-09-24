//
//  EventItem.m
//  sportsbuddy
//
//  Created by DoodleJack on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "EventItem.h"

@implementation EventItem

- (NSComparisonResult)compare:(EventItem *)otherEvent {
    return [self.eventTime compare:otherEvent.eventTime];
}

@end
