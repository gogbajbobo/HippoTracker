//
//  STHTLapCheckpoint.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/14/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STHTLap;

@interface STHTLapCheckpoint : STDatum

@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * pointNumber;
@property (nonatomic, retain) STHTLap *lap;

@end
