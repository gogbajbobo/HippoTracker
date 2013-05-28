//
//  STAccelData.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/28/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STDatum.h"

@class STHTLap;

@interface STAccelData : STDatum

@property (nonatomic, retain) NSString * accelData;
@property (nonatomic, retain) STHTLap *lap;

@end
