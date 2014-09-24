//
//  EventMapViewController.m
//  sportsbuddy
//
//  Created by DoodleJack on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import "EventMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EventPin.h"
#import "EventItem.h"
#import "MyButton.h"
#import "AddEventViewController.h"
#import "MyCustomAnnotation.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Parse/Parse.h>

#define METERS_PER_MILE 1609.344

@interface EventMapViewController () <MKMapViewDelegate, MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *subTitle;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (void)updateMapViewAnnotation;

@end

@implementation EventMapViewController {
    BOOL locationFound;
    EventPin *selectedPin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationFound = NO;
    self.eventPinMapping = [[NSMutableDictionary alloc] init];
    self.pinButtonMapping = [[NSMutableDictionary alloc] init];
    
    // check if user is logged in
    if ([PFUser currentUser]) {
        self.eventItems = [[NSMutableArray alloc] init];
        self.mapView.delegate = self;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100m
        [self.locationManager startUpdatingLocation];
    
        UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(dismissUIView)];
        [_mapView addGestureRecognizer:tapRec];
    } else {
        // navigate to logged in
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadEventsData];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    
}

// zoom to current location
- (void)zoomToCurrentLocation {
    float spanX = 0.01;
    float spanY = 0.01;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    
    if (region.center.latitude * region.center.latitude > 0) {
        locationFound = YES;
    }
    
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!locationFound) {
        [self zoomToCurrentLocation];
    }
}

- (void)loadEventsData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                // create a EventItem object
                EventItem *event = [[EventItem alloc] init];
                // set NSDate object with number of milliseconds from 1970 1.1
                NSTimeInterval timeInterval = [object[@"dateMilliseconds"] doubleValue] / 1000;
                timeInterval += [object[@"hour"] doubleValue] * 60 * 60;
                timeInterval += [object[@"minute"] doubleValue] * 60;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                event.eventTime = date;
                event.eventMaxNum = [object[@"maxPeople"] intValue];
                event.eventType = object[@"sportType"];
                event.visibility = object[@"visibility"];
                event.eventLoc = object[@"addressText"];
                event.eventLocLatitude = [object[@"latitude"] doubleValue];
                event.eventLocLongitude = [object[@"longitude"] doubleValue];
                event.coordinate = CLLocationCoordinate2DMake(event.eventLocLatitude, event.eventLocLongitude);
                event.currentNum = [object[@"currentPeople"] intValue];
                event.eventID = [object objectId];
                
                // filter event pin
                PFUser *user = [PFUser currentUser];
                NSArray *teams = user[@"teamsJoined"];
                if ([teams containsObject:event.visibility ] ||
                     [event.visibility isEqualToString:@"Public"]) {
                    [self.eventItems addObject:event];
                }
            }
            [self updateMapViewAnnotation];
        }
    }];
    
}

- (void)updateMapViewAnnotation
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd,hh:mm"];
    
    // clear eventPinMapping
    [self.eventPinMapping removeAllObjects];
    
    for (EventItem *aEvent in self.eventItems) {
        EventPin *annotation = [[EventPin alloc] initWithCoordinate:aEvent.coordinate title:[NSString stringWithFormat:@"%@", aEvent.eventType] subTitle:[NSString stringWithFormat:@"Time: %@", [formatter stringFromDate:aEvent.eventTime]]];
        
        [self.eventPinMapping setObject:aEvent forKey:[NSNumber numberWithUnsignedInteger:[annotation hash]]]; // use default hash code
        [self.mapView addAnnotation:annotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[EventPin class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
            
            // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view
            UIButton *rightButton = (UIButton *)[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(AnnotationClicked:) forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
        
    }
    return nil;
}


// track when an annotation is selected
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    selectedPin = (EventPin *)view.annotation;
    
}


- (void)AnnotationClicked:(id) sender{
    
    self.selectedEvent = [self.eventPinMapping objectForKey:[NSNumber numberWithUnsignedInteger:[selectedPin hash]]];
    
    CGSize  calloutSize = CGSizeMake(_mapView.frame.size.width - 40, 235.0);
    UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(_mapView.frame.origin.x + 20, _mapView.frame.size.height -calloutSize.height, calloutSize.width, calloutSize.height)];
    
    calloutView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    calloutView.opaque = NO;
    
    UILabel *labelType = [[UILabel alloc] initWithFrame:CGRectMake(20, 5,calloutSize.width , 20)];
    [labelType setTextColor:[UIColor whiteColor]];
    [labelType setText:[NSString stringWithFormat:@"Sports Type:    %@", self.selectedEvent.eventType]];
    
    UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(20, 30,calloutSize.width , 20)];
    [labelTime setTextColor:[UIColor whiteColor]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd,hh:mm"];
    [labelTime setText:[NSString stringWithFormat:@"Time:     %@", [formatter stringFromDate:self.selectedEvent.eventTime]]];
    
    UILabel *labelLoc = [[UILabel alloc] initWithFrame:CGRectMake(20, 55,calloutSize.width , 20)];
    [labelLoc setTextColor:[UIColor whiteColor]];
    NSString *locText = self.selectedEvent.eventLoc;
    NSRange range = [locText rangeOfString:@","];
    if (range.location != NSNotFound) {
        locText = [NSString stringWithString:[locText substringToIndex:range.location]];
    }
    [labelLoc setText:[NSString stringWithFormat:@"Location:    %@", locText]];
    
    UILabel *labelMax = [[UILabel alloc] initWithFrame:CGRectMake(20, 80,calloutSize.width , 20)];
    [labelMax setTextColor:[UIColor whiteColor]];
    [labelMax setText:[NSString stringWithFormat:@"Max Participants:         %d", self.selectedEvent.eventMaxNum]];
    
    UILabel *labelCurr = [[UILabel alloc] initWithFrame:CGRectMake(20, 105,calloutSize.width , 20)];
    [labelCurr setTextColor:[UIColor whiteColor]];
    [labelCurr setText:[NSString stringWithFormat:@"Current Participants:    %d", self.selectedEvent.currentNum]];
    
    UILabel *labelVisibility = [[UILabel alloc] initWithFrame:CGRectMake(20, 130,calloutSize.width , 20)];
    [labelVisibility setTextColor:[UIColor whiteColor]];
    [labelVisibility setText:[NSString stringWithFormat:@"Visibility:    %@", self.selectedEvent.visibility]];
    
    UILabel *labelNotes = [[UILabel alloc] initWithFrame:CGRectMake(20, 155,calloutSize.width , 20)];
    [labelNotes setTextColor:[UIColor whiteColor]];
    if (self.selectedEvent.eventNote != nil) {
        [labelNotes setText: [NSString stringWithFormat:@"Notes:    %@", self.selectedEvent.eventNote]];
    } else {
        [labelNotes setText: [NSString stringWithFormat:@"Notes:"]];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, 190, calloutSize.width - 40, 30);
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTintColor:[UIColor redColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [button setTitle:@"Join" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(joinButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [calloutView addSubview:button];
    [calloutView addSubview:labelType];
    [calloutView addSubview:labelTime];
    [calloutView addSubview:labelLoc];
    [calloutView addSubview:labelMax];
    [calloutView addSubview:labelCurr];
    [calloutView addSubview:labelVisibility];
    [calloutView addSubview:labelNotes];
    
    calloutView.tag = 1;
    [_mapView addSubview:calloutView];
}

- (void)dismissUIView {
    [[_mapView viewWithTag:1] removeFromSuperview];
}

- (void)joinButtonClicked{
    [self dismissUIView];
    
    // save to back-end and ask user to share to twitter
    NSString *eventID = self.selectedEvent.eventID;
    PFObject *event = [PFQuery getObjectOfClass:@"Event" objectId:eventID];
    

    PFUser *user = [PFUser currentUser];
    NSArray *eventList = user[@"eventsJoined"];
    
    // check if user already part of the team
    if ([eventList containsObject:eventID]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"You already joined this event" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        
        // increment number of people
        NSNumber *currentPeople = event[@"currentPeople"];
        currentPeople = [NSNumber numberWithInt:[currentPeople intValue] + 1];
        event[@"currentPeople"] = currentPeople;
        
        // add current user to participating user list
        NSMutableArray *participants = event[@"participants"];
        [participants addObject:[[PFUser currentUser] objectId]];
        event[@"participants"] = [NSArray arrayWithArray:participants];
        
        // save in background
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Error occurred, possibly network error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have succesfully joined this event. Would you like to share it on Twitter?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Yes", nil];
                [alertView show];
            }
        }];
        
        // add this event to user's events list
        PFUser *user = [PFUser currentUser];
        [user[@"eventsJoined"] addObject:eventID];
        [user saveInBackground];
    }
}

// create default twitter message
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // check whether user already setup an account on device
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *tweetBox = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetBox setInitialText:[self createDefaultTweet]];
            [self presentViewController:tweetBox animated:YES completion:nil];
        }
        else {
            // alert user to setup account
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"No Twitter account found on device.\
                                      Go to \"Settings\" to setup."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (NSString *)createDefaultTweet {
    
    EventItem *event = self.selectedEvent;
    NSString *tweet = @"Join me to play ";
    tweet = [tweet stringByAppendingString:event.eventType];
    tweet = [tweet stringByAppendingString:@" in "];
    tweet = [tweet stringByAppendingString:event.eventLoc];
    tweet = [tweet stringByAppendingString:@" at "];
    NSDate *date = event.eventTime;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm, MMM dd"];
    tweet = [tweet stringByAppendingString:[formatter stringFromDate:date]];
    return tweet;
}


- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotation];
}


- (IBAction)unwindToMap:(UIStoryboardSegue *)segue
{
    AddEventViewController *source = [segue sourceViewController];
    self.selectedEvent = source.eventItem;
    EventItem *newItem = source.eventItem;
    if (newItem != nil) {
        [self.eventItems addObject:newItem];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newItem.coordinate, 1.3*METERS_PER_MILE, 1.3*METERS_PER_MILE);
        [self.mapView setRegion:viewRegion animated:YES];
        [self updateMapViewAnnotation];
    }
}


@end