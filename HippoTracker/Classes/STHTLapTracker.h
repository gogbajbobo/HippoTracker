//
//  STGTLocationTracker.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STTracker.h"
#import "STHTHippodrome.h"
#import "STHTLap.h"

@interface STHTLapTracker : STTracker

@property (nonatomic, strong) STHTHippodrome *hippodrome;
@property (nonatomic) CLLocationAccuracy currentAccuracy;
@property (nonatomic, strong) STHTLap *currentLap;

- (void)startNewLap;
//- (void)deleteLap:(STHTLap *)lap;

@end
