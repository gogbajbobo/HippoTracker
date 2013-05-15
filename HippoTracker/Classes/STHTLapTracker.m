//
//  STGTLocationTracker.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STHTLapTracker.h"
#import "STHTLocation.h"

@interface STHTLapTracker() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
//@property (nonatomic, strong) STHTTrack *currentTrack;

@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) double requiredAccuracy;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) NSTimeInterval timeFilter;
//@property (nonatomic) NSTimeInterval trackDetectionTime;
//@property (nonatomic) CLLocationDistance trackSeparationDistance;

@property (nonatomic) BOOL lapTracking;

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
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
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
                if (!self.lastLocation) {
                    self.lastLocation = newLocation;
                }
                [self addLocation:newLocation];
            }
        }
    }
    
}

#pragma mark - track management

- (void)addLocation:(CLLocation *)currentLocation {

    [self.currentLap addLocationsObject:[self locationObjectFromCLLocation:currentLocation]];
    self.lastLocation = currentLocation;
    
    [self.document saveDocument:^(BOOL success) {
        NSLog(@"save newLocation");
        if (success) {
            NSLog(@"save newLocation success");
        }
    }];
  
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
