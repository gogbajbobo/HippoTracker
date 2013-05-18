//
//  STMovementAnalyzer.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/18/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "STQueue.h"
#import <STManagedTracker/STSessionManagement.h>


@interface STMovementAnalyzer : NSObject

@property (nonatomic, strong) id <STSession> sesstion;
@property (nonatomic, strong) STQueue *locationsQueue;
@property (nonatomic, strong) STQueue *accelerometerQueue;
@property (nonatomic) BOOL GPSMovingDetected;

- (void)addLocation:(CLLocation *)location;

@end
