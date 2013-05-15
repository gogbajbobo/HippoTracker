//
//  STHTHippodrome.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STHTLap;

@interface STHTHippodrome : STDatum

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *laps;
@end

@interface STHTHippodrome (CoreDataGeneratedAccessors)

- (void)addLapsObject:(STHTLap *)value;
- (void)removeLapsObject:(STHTLap *)value;
- (void)addLaps:(NSSet *)values;
- (void)removeLaps:(NSSet *)values;

@end
