//
//  STMovementAnalyzer.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/18/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMovementAnalyzer.h"
#import <STManagedTracker/STSession.h>

@implementation STMovementAnalyzer

- (STQueue *)locationsQueue {
    if (!_locationsQueue) {
        _locationsQueue = [[STQueue alloc] init];
    }
    return _locationsQueue;
}

- (void)addLocation:(CLLocation *)location {
    
    [self.locationsQueue enqueue:location];
    
    if (self.locationsQueue.filled) {
        CLLocationDistance distanceFilter = [[[[(STSession *)self.sesstion locationTracker] settings] valueForKey:@"distanceFilter"] doubleValue];
        
        if (self.GPSMovingDetected) {
            CLLocation *followingLocation = [self.locationsQueue tail];
            if (followingLocation) {
                BOOL moving = NO;
                for (int i = self.locationsQueue.count - 2; i >= 0; i--) {
                    CLLocation *location = [self.locationsQueue objectAtIndex:i];
                    moving |= [self enoughOfDistanceFrom:location to:followingLocation distanceFilter:distanceFilter];
                    if (moving) {
//                        NSLog(@"moving");
                        break;
                    }
                    followingLocation = location;
                }
                if (!moving) {
                    self.GPSMovingDetected = moving;
                }
            } else {

            }
            
        } else {
            CLLocation *prevLocation = [self.locationsQueue head];
            if (prevLocation) {
                BOOL moving = YES;
                for (int i = 1; i < self.locationsQueue.count; i++) {
                    CLLocation *location = [self.locationsQueue objectAtIndex:i];
                    moving &= [self enoughOfDistanceFrom:location to:prevLocation distanceFilter:distanceFilter];
                    if (!moving) {
//                        NSLog(@"not moving");
                        break;
                    }
                    prevLocation = location;
                }
                if (moving) {
                    self.GPSMovingDetected = moving;
                }
            } else {
                
            }
        }
    }
    
}


- (BOOL)enoughOfDistanceFrom:(CLLocation *)location to:(CLLocation *)previousLocation distanceFilter:(CLLocationDistance)distanceFilter {
    return ([location distanceFromLocation:previousLocation] > distanceFilter);
}


@end
