//
//  STLapTracker.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <STManagedTracker/STTracker.h>
#import <CoreLocation/CoreLocation.h>
#import "STHTHippodrome.h"
#import "STHTLap.h"
#import "STMovementAnalyzer.h"


@interface STHTLapTracker : STTracker

@property (nonatomic, strong) STHTHippodrome *hippodrome;
@property (nonatomic) CLLocationAccuracy currentAccuracy;
@property (nonatomic, strong) STHTLap *currentLap;
@property (nonatomic) BOOL lapTracking;
@property (nonatomic, strong) STMovementAnalyzer *movementAnalyzer;

- (void)startNewLapAtTime:(NSDate *)timestamp;
- (void)finishLap;
- (void)deleteLap:(STHTLap *)lap;

@end
