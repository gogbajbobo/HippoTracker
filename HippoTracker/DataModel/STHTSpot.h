//
//  STHTSpot.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/9/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTDatum.h"

@class STHTSpotImage;

@interface STHTSpot : STHTDatum

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * avatarXid;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *interests;
@property (nonatomic, retain) NSSet *networks;
@end

@interface STHTSpot (CoreDataGeneratedAccessors)

- (void)addImagesObject:(STHTSpotImage *)value;
- (void)removeImagesObject:(STHTSpotImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addInterestsObject:(NSManagedObject *)value;
- (void)removeInterestsObject:(NSManagedObject *)value;
- (void)addInterests:(NSSet *)values;
- (void)removeInterests:(NSSet *)values;

- (void)addNetworksObject:(NSManagedObject *)value;
- (void)removeNetworksObject:(NSManagedObject *)value;
- (void)addNetworks:(NSSet *)values;
- (void)removeNetworks:(NSSet *)values;

@end
