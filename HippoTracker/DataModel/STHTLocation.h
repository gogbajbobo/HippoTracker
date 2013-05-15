//
//  STHTLocation.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STLocation.h"

@class STHTLap;

@interface STHTLocation : STLocation

@property (nonatomic, retain) STHTLap *lap;

@end
