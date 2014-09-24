//
//  MyButton.h
//  sportsbuddy
//
//  Created by Wenting Shi on 7/30/14.
//  Copyright (c) 2014 Carnegie_Mellon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventPin.h"

@interface MyButton : UIButton

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) EventPin *selectedPin;

@end
