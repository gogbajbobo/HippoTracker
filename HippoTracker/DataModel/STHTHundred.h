//
//  STHTHundred.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/14/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTDatum.h"

@class STHTLap;

@interface STHTHundred : STHTDatum

@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) STHTLap *lap;

@end
