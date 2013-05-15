//
//  STHTLap.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STHTHippodrome, STHTLapCheckpoint, STHTLocation;

@interface STHTLap : STDatum

@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSSet *checkpoints;
@property (nonatomic, retain) STHTHippodrome *hippodrome;
@property (nonatomic, retain) NSSet *locations;
@end

@interface STHTLap (CoreDataGeneratedAccessors)

- (void)addCheckpointsObject:(STHTLapCheckpoint *)value;
- (void)removeCheckpointsObject:(STHTLapCheckpoint *)value;
- (void)addCheckpoints:(NSSet *)values;
- (void)removeCheckpoints:(NSSet *)values;

- (void)addLocationsObject:(STHTLocation *)value;
- (void)removeLocationsObject:(STHTLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
