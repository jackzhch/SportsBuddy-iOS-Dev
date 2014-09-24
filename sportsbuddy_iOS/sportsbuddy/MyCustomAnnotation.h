//
//  CalloutAnnotation.h
//  sportsbuddy
//
//  Created by DoodleJack on 8/2/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MyCustomAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;

// Other methods and properties.
@end