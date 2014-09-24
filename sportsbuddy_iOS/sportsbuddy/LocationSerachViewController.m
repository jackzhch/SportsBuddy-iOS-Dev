//
//  LocationSerachViewController.m
//  sportsbuddy
//
//  Created by DoodleJack on 8/1/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "LocationSerachViewController.h"
#import "AddEventViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EventPin.h"
#import "EventItem.h"

#define METERS_PER_MILE 1609.344

@interface LocationSerachViewController () <MKMapViewDelegate, MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) NSMutableArray *eventItems;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation LocationSerachViewController {
    CLPlacemark *placemark;
    BOOL locationFound;
    NSString *locationText;
    MKPointAnnotation *previousAnnotation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    self.eventItem = [[EventItem alloc]init];
    self.mapView.delegate = self;
    locationFound = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100m
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    
    // long press gesture listener to call for action of adding annotation
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleGesture:)];
    lpgr.minimumPressDuration = 0.5;  //user must press for 0.5 seconds
    [_mapView addGestureRecognizer:lpgr];
    
}

- (void)dismissKeyboard
{
    [self.searchText resignFirstResponder];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    
    [self.delegate updateLocation:locationText withLatitude:self.positionLatitude andLongitude:self.positionLongitude];
    [self dismissViewControllerAnimated:YES completion:nil];
}


// zoom to current location
- (void)zoomToCurrentLocation {
    float spanX = 0.075;
    float spanY = 0.075;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    
    if (region.center.latitude * region.center.latitude > 0) {
        locationFound = YES;
    }
    
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:NO];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!locationFound) {
        [self zoomToCurrentLocation];
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = touchMapCoordinate;
    
    // Reverse geocoding
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            annotation.title = [NSString stringWithFormat:@"%@ %@",
                             placemark.subThoroughfare, placemark.thoroughfare];
            locationText = annotation.title;
            self.positionLatitude = [NSNumber numberWithFloat:annotation.coordinate.latitude];
            self.positionLongitude = [NSNumber numberWithFloat:annotation.coordinate.longitude];
            if (previousAnnotation != nil) {
                // remove previous annotation
                [self.mapView removeAnnotation:previousAnnotation];
            }
            [self.mapView addAnnotation:annotation];
            previousAnnotation = annotation;
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}


- (IBAction)searchLocation:(UIButton *)sender {
    
    // forward geocoding
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@", self.searchText.text] completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark* aPlacemark in placemarks)
        {
            self.eventItem.coordinate = aPlacemark.location.coordinate;
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
            annotation.coordinate = aPlacemark.location.coordinate;
            self.eventItem.eventLoc = annotation.title;
            
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_eventItem.coordinate, 1.3*METERS_PER_MILE, 1.3*METERS_PER_MILE);
            [self.mapView setRegion:viewRegion animated:YES];
            
            // set the annotation title after reverse geocoding
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                    annotation.title = [NSString stringWithFormat:@"%@ %@",
                                        placemark.subThoroughfare, placemark.thoroughfare];
                    locationText = annotation.title;
                    self.positionLatitude = [NSNumber numberWithFloat:annotation.coordinate.latitude];
                    self.positionLongitude = [NSNumber numberWithFloat:annotation.coordinate.longitude];
                    if (previousAnnotation != nil) {
                        // remove previous annotation
                        [self.mapView removeAnnotation:previousAnnotation];
                    }
                    [self.mapView addAnnotation:annotation];
                    previousAnnotation = annotation;
                } else {
                    NSLog(@"%@", error.debugDescription);
                }
            } ];
            
        }
    }];
}


@end