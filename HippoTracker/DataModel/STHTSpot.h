//
//  STHTSpot.h
//  HippoTracker
//
//  Created by Maxim Grigoriev on 5/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STHTDatum.h"


@interface STHTSpot : STHTDatum

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * latitude1;
@property (nonatomic, retain) NSNumber * longitude1;
@property (nonatomic, retain) NSNumber * latitude2;
@property (nonatomic, retain) NSNumber * longitude2;

@end
