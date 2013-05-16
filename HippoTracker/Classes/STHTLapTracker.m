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

@interface STHTLapTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) NSTimeInterval timeFilter;
@property (nonatomic) CLLocationDistance checkpointDistance;
@property (nonatomic, strong) NSDate *checkpointTime;
@property (nonatomic) NSTimeInterval overlapTime;


@end

@implementation STHTLapTracker

@synthesize desiredAccuracy = _desiredAccuracy;
@synthesize distanceFilter = _distanceFilter;


- (void)customInit {
    self.group = @"location";
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
    if (locationAge < 5.0 && newLocation.horizontalAccuracy > 0) {
        self.currentAccuracy = newLocation.horizontalAccuracy;
        if (newLocation.horizontalAccuracy <= self.requiredAccuracy) {
            if (self.lapTracking) {
                if (self.locationManager.distanceFilter == 0) {
                    self.currentLap.startTime = [NSDate date];
                    self.checkpointTime = self.currentLap.startTime;
                    self.overlapTime = 0;
                    self.checkpointDistance = 0;
                    self.locationManager.distanceFilter = -1;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"lapTracking" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:self.locationManager.distanceFilter] forKey:@"distanceFilter"]];
                }
                [self addLocation:newLocation];
            }
        }
    }
    
}

#pragma mark - lap management

- (void)addLocation:(CLLocation *)currentLocation {
    
    [self.currentLap addLocationsObject:[self locationObjectFromCLLocation:currentLocation]];
    
    if (self.lastLocation) {
        [self calculateDistance:currentLocation];
    }
    self.lastLocation = currentLocation;
    
    [self.document saveDocument:^(BOOL success) {
        NSLog(@"save newLocation");
        if (success) {
            NSLog(@"save newLocation success");
        }
    }];
    
}

- (void)calculateDistance:(CLLocation *)location {
    CLLocationDistance distance = [location distanceFromLocation:self.lastLocation];
    self.checkpointDistance += distance;
    if (self.checkpointDistance >= HTCheckpointInterval) {
        self.checkpointDistance -= HTCheckpointInterval;
        NSTimeInterval time = [location.timestamp timeIntervalSinceDate:self.lastLocation.timestamp];
        NSTimeInterval t = time - (self.checkpointDistance * time) / distance;
        [self addCheckpointWithTime:[self.lastLocation.timestamp timeIntervalSinceDate:self.checkpointTime] + self.overlapTime + t];
        self.checkpointTime = [NSDate dateWithTimeInterval:t sinceDate:self.lastLocation.timestamp];
        self.overlapTime = time - t;
    }
}

- (void)addCheckpointWithTime:(NSTimeInterval)time {
    STHTLapCheckpoint *checkpoint = (STHTLapCheckpoint *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTLapCheckpoint" inManagedObjectContext:self.document.managedObjectContext];
    checkpoint.checkpointNumber = [NSNumber numberWithInt:self.currentLap.checkpoints.count];
    checkpoint.time = [NSNumber numberWithDouble:time];
    checkpoint.speed = [NSNumber numberWithDouble:3.6 * HTCheckpointInterval / time];
    [self.currentLap addCheckpointsObject:checkpoint];
}

- (void)startNewLap {
    
    STHTLap *lap = (STHTLap *)[NSEntityDescription insertNewObjectForEntityForName:@"STHTLap" inManagedObjectContext:self.document.managedObjectContext];
    self.currentLap = lap;
    [self.hippodrome addLapsObject:lap];
    self.lapTracking = YES;
    [self.document saveDocument:^(BOOL success) {
        NSLog(@"save newLap");
        if (success) {
            NSLog(@"save newLap success");
        }
    }];
    
}

- (void)finishLap {
    self.lapTracking = NO;
    self.locationManager.distanceFilter = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lapTracking" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:self.locationManager.distanceFilter] forKey:@"distanceFilter"]];
    if (!self.currentLap.startTime) {
        [self.document.managedObjectContext deleteObject:self.currentLap];
        self.currentLap = nil;
    }
    [self.document saveDocument:^(BOOL success) {
        NSLog(@"save lap");
        if (success) {
            NSLog(@"save lap success");
        }
    }];
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
