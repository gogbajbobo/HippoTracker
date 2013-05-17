//
//  STHTLapCheckpoint.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/17/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STHTLap;

@interface STHTLapCheckpoint : STDatum

@property (nonatomic, retain) NSNumber * checkpointNumber;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * interval;
@property (nonatomic, retain) STHTLap *lap;

@end
