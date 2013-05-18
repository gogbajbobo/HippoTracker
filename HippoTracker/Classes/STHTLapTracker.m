//
//  STLapTracker.m
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/15/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTLapTracker.h"
#import "STHTLocation.h"
#import "STHTLapCheckpoint.h"
#import <STManagedTracker/STSession.h>

@interface STHTLapTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) NSTimeInterval timeFilter;
@property (nonatomic) CLLocationDistance checkpointDistance;
@property (nonatomic, strong) NSDate *checkpointTime;
@property (nonatomic, strong) STHTLapCheckpoint *lastCheckpoint;
@property (nonatomic) CLLocationDistance checkpointInterval;
@property (nonatomic) double slowdownValue;


@end

@implementation STHTLapTracker

@synthesize desiredAccuracy = _desiredAccuracy;
@synthesize distanceFilter = _distanceFilter;


- (void)customInit {
    self.group = @"location";
    self.currentLap = nil;
    [super customInit];
}

- (STHTHippodrome *)hippodrome {
    if (!_hippodrome) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STHTHippodrome"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        NSError *error;
        STHTHippodrome *hippodrome = [[self.document.managedObjectContext executeFetchRequest:request error:&error] lastObject];
        if (!hippodrome) {
            hippodrome = (STHTHippodrome *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTHippodrome" inManagedObjectContext:self.document.managedObjectContext];
        }
        _hippodrome = hippodrome;
    }
    return _hippodrome;
}

#pragma mark - locationTracker settings

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([change valueForKey:NSKeyValueChangeNewKey] != [change valueForKey:NSKeyValueChangeOldKey]) {
        if ([keyPath isEqualToString:@"distanceFilter"] || [keyPath isEqualToString:@"desiredAccuracy"]) {
            self.locationManager.desiredAccuracy = [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
            self.locationManager.distanceFilter = [[self.settings valueForKey:@"distanceFilter"] doubleValue];
        }
    }
    
}

- (CLLocationAccuracy) desiredAccuracy {
    return [[self.settings valueForKey:@"desiredAccuracy"] doubleValue];
}

- (double)requiredAccuracy {
    return [[self.settings valueForKey:@"requiredAccuracy"] doubleValue];
}


- (CLLocationDistance)distanceFilter {
    return [[self.settings valueForKey:@"distanceFilter"] doubleValue];
}

- (NSTimeInterval)timeFilter {
    return [[self.settings valueForKey:@"timeFilter"] doubleValue];
}

- (CLLocationDistance)checkpointInterval {
    return [[self.settings valueForKey:@"HTCheckpointInterval"] doubleValue];
}

- (double)slowdownValue {
    return [[self.settings valueForKey:@"HTSlowdownValue"] doubleValue];
}

- (void)setCurrentAccuracy:(CLLocationAccuracy)currentAccuracy {
    if (_currentAccuracy != currentAccuracy) {
        _currentAccuracy = currentAccuracy;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentAccuracyChanged" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:_currentAccuracy] forKey:@"currentAccuracy"]];
    }
}

#pragma mark - tracking

- (void)startTracking {
    [super startTracking];
    if (self.tracking) {
        [[self locationManager] startUpdatingLocation];
    }
}

- (void)stopTracking {
    [[self locationManager] stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    [super stopTracking];
}


#pragma mark - CLLocationManager

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = self.distanceFilter;
        _locationManager.desiredAccuracy = self.desiredAccuracy;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lapTracking" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:_locationManager.distanceFilter] forKey:@"distanceFilter"]];
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge < 2.0 && newLocation.horizontalAccuracy > 0) {
        self.currentAccuracy = newLocation.horizontalAccuracy;
        if (newLocation.horizontalAccuracy <= self.requiredAccuracy) {
            if (self.lapTracking) {
                if (!self.currentLap) {
//                    NSLog(@"newLocation.timestamp %@", newLocation.timestamp);
                    [self startNewLapAtTime:newLocation.timestamp];
                }
                [self addLocation:newLocation];
            }
        }
    }
    
}

#pragma mark - lap management

- (void)startNewLapAtTime:(NSDate *)timestamp {
    
    if (self.lapTracking) {
        STHTLap *lap = (STHTLap *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTLap" inManagedObjectContext:self.document.managedObjectContext];
        self.currentLap = lap;
        [self.hippodrome addLapsObject:lap];
        self.currentLap.startTime = timestamp;
        self.checkpointTime = self.currentLap.startTime;
        self.checkpointDistance = 0;
        self.lastLocation = nil;
        self.lastCheckpoint = nil;
        self.locationManager.distanceFilter = -1;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lapTracking" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:self.locationManager.distanceFilter] forKey:@"distanceFilter"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startNewLap" object:self userInfo:[NSDictionary dictionaryWithObject:self.currentLap forKey:@"currentLap"]];
        [[(STSession *)self.session logger] saveLogMessageWithText:@"startNewLap" type:@""];
        [self.document saveDocument:^(BOOL success) {
            if (success) {
//                NSLog(@"save newLap success");
            } else {
                NSLog(@"save newLap NO success");
            }
        }];
    }
    
}

- (void)addLocation:(CLLocation *)currentLocation {
    
    [self.currentLap addLocationsObject:[self locationObjectFromCLLocation:currentLocation]];
    
    if (self.lastLocation) {
        [self calculateDistance:currentLocation];
    }
    self.lastLocation = currentLocation;
    
    [self.document saveDocument:^(BOOL success) {
//        NSLog(@"save newLocation");
        if (success) {
//            NSLog(@"save newLocation success");
        } else {
            NSLog(@"save newLocation NO success");
        }
    }];
    
}

- (void)calculateDistance:(CLLocation *)location {
    CLLocationDistance distance = [location distanceFromLocation:self.lastLocation];
    if (distance == 0) {
//        [self stopDetected];
    } else {
        self.checkpointDistance += distance;
        if (self.checkpointDistance >= self.checkpointInterval) {
            self.checkpointDistance -= self.checkpointInterval;
            NSTimeInterval time = [location.timestamp timeIntervalSinceDate:self.lastLocation.timestamp];
            NSTimeInterval t = time - (self.checkpointDistance * time) / distance;
            [self addCheckpointWithTime:[self.lastLocation.timestamp timeIntervalSinceDate:self.checkpointTime] + t];
            self.checkpointTime = [NSDate dateWithTimeInterval:t sinceDate:self.lastLocation.timestamp];
        }
    }
}

- (void)addCheckpointWithTime:(NSTimeInterval)time {
    if (self.lastCheckpoint.time) {
        CLLocationSpeed lastCheckpointSpeed = [self.lastCheckpoint.interval doubleValue] / [self.lastCheckpoint.time doubleValue];
        CLLocationSpeed currentSpeed = self.checkpointInterval / time;
        CLLocationSpeed compareSpeed = lastCheckpointSpeed * self.slowdownValue;
        if (currentSpeed < compareSpeed) {
//            [[(STSession *)self.session logger] saveLogMessageWithText:@"stopDetected by slowdown" type:@""];
//            [self stopDetected];
        }
    }
    if (self.lapTracking) {
        STHTLapCheckpoint *checkpoint = (STHTLapCheckpoint *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTLapCheckpoint" inManagedObjectContext:self.document.managedObjectContext];
        checkpoint.checkpointNumber = [NSNumber numberWithInt:self.currentLap.checkpoints.count];
        checkpoint.time = [NSNumber numberWithDouble:time];
        checkpoint.speed = [NSNumber numberWithDouble:3.6 * self.checkpointInterval / time];
        checkpoint.interval = [NSNumber numberWithDouble:self.checkpointInterval];
        [self.currentLap addCheckpointsObject:checkpoint];
        self.lastCheckpoint = checkpoint;
    }
}

- (void)finishLap {
    self.lapTracking = NO;
    self.locationManager.distanceFilter = self.distanceFilter;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lapTracking" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:self.locationManager.distanceFilter] forKey:@"distanceFilter"]];
//    if (!self.currentLap.startTime) {
//        [self.document.managedObjectContext deleteObject:self.currentLap];
//        self.currentLap = nil;
//    }
    self.currentLap = nil;
    [[(STSession *)self.session logger] saveLogMessageWithText:@"finishLap" type:@""];
    [self.document saveDocument:^(BOOL success) {
//        NSLog(@"save lap");
        if (success) {
            NSLog(@"save lap success");
        } else {
            NSLog(@"save lap NO success");
        }
    }];
}

- (void)stopDetected {
    [self finishLap];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopDetected" object:self userInfo:nil];
}

- (STHTLocation *)locationObjectFromCLLocation:(CLLocation *)location {
    STHTLocation *locationObject = (STHTLocation *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTLocation" inManagedObjectContext:self.document.managedObjectContext];
    [locationObject setLatitude:[NSNumber numberWithDouble:location.coordinate.latitude]];
    [locationObject setLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
    [locationObject setHorizontalAccuracy:[NSNumber numberWithDouble:location.horizontalAccuracy]];
    [locationObject setSpeed:[NSNumber numberWithDouble:location.speed]];
    [locationObject setCourse:[NSNumber numberWithDouble:location.course]];
    [locationObject setAltitude:[NSNumber numberWithDouble:location.altitude]];
    [locationObject setVerticalAccuracy:[NSNumber numberWithDouble:location.verticalAccuracy]];
    [locationObject setTimestamp:location.timestamp];
    return locationObject;
}

- (CLLocation *)locationFromLocationObject:(STLocation *)locationObject {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationObject.latitude doubleValue], [locationObject.longitude doubleValue]);
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                         altitude:[locationObject.altitude doubleValue]
                                               horizontalAccuracy:[locationObject.horizontalAccuracy doubleValue]
                                                 verticalAccuracy:[locationObject.verticalAccuracy doubleValue]
                                                           course:[locationObject.course doubleValue]
                                                            speed:[locationObject.speed doubleValue]
                                                        timestamp:locationObject.timestamp];
    return location;
}


@end
