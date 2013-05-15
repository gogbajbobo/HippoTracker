//
//  STGTLocationTracker.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTHippodrome.h"
#import "STHTLap.h"
#import <STManagedTracker/STTracker.h>

@interface STHTLapTracker : STTracker

@property (nonatomic, strong) STHTHippodrome *hippodrome;
@property (nonatomic) CLLocationAccuracy currentAccuracy;
@property (nonatomic, strong) STHTLap *currentLap;
@property (nonatomic) BOOL lapTracking;

- (void)startNewLap;
- (void)finishLap;

@end
