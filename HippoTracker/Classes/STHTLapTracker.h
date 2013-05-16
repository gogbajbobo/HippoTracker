//
//  STLapTracker.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <STManagedTracker/STTracker.h>
#import "STHTHippodrome.h"
#import "STHTLap.h"

#define HTCheckpointInterval 10.0
#define HTSlowdownValue 0.7

@interface STHTLapTracker : STTracker

@property (nonatomic, strong) STHTHippodrome *hippodrome;
@property (nonatomic) CLLocationAccuracy currentAccuracy;
@property (nonatomic, strong) STHTLap *currentLap;
@property (nonatomic) BOOL lapTracking;

- (void)startNewLap;
- (void)finishLap;

@end
