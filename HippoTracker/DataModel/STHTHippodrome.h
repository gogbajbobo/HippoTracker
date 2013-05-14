//
//  STHTHippodrome.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/13/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTDatum.h"

@class STHTLap;

@interface STHTHippodrome : STHTDatum

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * startLineLat1;
@property (nonatomic, retain) NSNumber * startLineLat2;
@property (nonatomic, retain) NSNumber * startLineLon1;
@property (nonatomic, retain) NSNumber * startLineLon2;
@property (nonatomic, retain) NSSet *laps;
@end

@interface STHTHippodrome (CoreDataGeneratedAccessors)

- (void)addLapsObject:(STHTLap *)value;
- (void)removeLapsObject:(STHTLap *)value;
- (void)addLaps:(NSSet *)values;
- (void)removeLaps:(NSSet *)values;

@end
