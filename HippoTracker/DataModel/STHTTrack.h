//
//  STHTTrack.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTDatum.h"

@class STHTLocation;

@interface STHTTrack : STHTDatum

@property (nonatomic, retain) NSDate * finishTime;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSSet *locations;
@end

@interface STHTTrack (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(STHTLocation *)value;
- (void)removeLocationsObject:(STHTLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
